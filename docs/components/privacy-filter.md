# Privacy Filter

The **Privacy Filter** is an optional service that redacts personal data (PII) from text before Lightrun stores it. It runs the `openai/privacy-filter` model on a GPU and replaces detected private values with `<REDACTED>`.

When enabled, the backend sends candidate text from **snapshots** and **logs** to the service and stores the returned redacted values.

> [!IMPORTANT]
> Enabling Privacy Filter adds a GPU workload and increases RabbitMQ resource requirements. This can create significant infrastructure costs. Review [GPU node requirements](#gpu-node-requirements) and capacity with your infrastructure team before enabling it.

> [!NOTE]
> Privacy Filter is **disabled by default** and requires RabbitMQ (`general.mq.enabled: true`), an NVIDIA GPU node, and a compatible NVIDIA container runtime.

## How it works

```
                      RabbitMQ
                ┌──────────────────────────┐
Backend ──────► │ privacy-filter-requests  │ ──────► Privacy Filter
Backend ◄────── │ privacy-filter-responses │ ◄──────
                └──────────────────────────┘
```

Privacy Filter communicates only through two **RabbitMQ queues**: it reads requests from `privacy-filter-requests` and writes replies to `privacy-filter-responses`.

1. The backend publishes the texts to redact to the request queue (in chunks of up to 1000 texts).
2. A Privacy Filter pod consumes them, runs the model and publishes the redacted texts, in the same order, to the response queue. Replies carry the request's `correlation_id` and an opaque context, so neither side keeps per-request state.
3. The backend consumes the reply and stores the completed data. While a snapshot is pending, candidate text sent for redaction is replaced with internal markers.

Privacy Filter has no inbound traffic and **no Kubernetes Service**: it only connects out to RabbitMQ. Its HTTP port (`8786`) serves just the `/health` and `/ready` probes.

### Failure behavior

For text selected for AI redaction, Lightrun rejects data that cannot be queued safely and uses a failure placeholder when processing cannot complete. AI detection is not a guarantee that every sensitive value will be identified; continue to use customer-configured PII patterns for organization-specific data.

| Situation | Result |
| --------- | ------ |
| Transient failure in the service (engine error, timeout) | Retried up to `rabbitmq.max_attempts` times. |
| Request can never succeed (invalid, too large) or retries exhausted | Error reply; the request moves to `<request queue>.dlq`. The backend stores `<PII_REDACTION_FAILED>` in place of the candidate text. |
| Request can't be queued (queue full, RabbitMQ down) | The agent's data is rejected with a `Retry-After`, so the agent retries. |
| No reply for a snapshot (e.g. request expired in RabbitMQ) | After approximately 65 minutes, the snapshot is stored with the missing candidate texts marked `<PII_REDACTION_FAILED>`. |

## Before you enable Privacy Filter

Confirm the following requirements:

- Your Lightrun and Helm chart versions include the Privacy Filter component.
- RabbitMQ is enabled in the chart.
- The cluster has a dedicated NVIDIA GPU node with a compatible NVIDIA container runtime and driver.
- Node labels and taints are available to keep the workload on the intended GPU node.
- The nodes have sufficient image storage. The model is embedded in a large container image and can take several minutes to pull and initialize.
- Your infrastructure team has reviewed the expected GPU and RabbitMQ costs.

The chart does not provision a GPU node by itself. In a cluster with node auto-provisioning, scheduling the Privacy Filter pod can cause an eligible GPU instance to be created. In a statically provisioned cluster, create the GPU node before enabling the component.

## Enable the Privacy Filter infrastructure

```yaml
general:
  mq:
    enabled: true
  privacy_filter:
    enabled: true
```

This setting:

- Deploys one Privacy Filter replica by default.
- Creates the request, response, and dead-letter queues.
- Configures the backend and cron services to use Privacy Filter.
- Applies the Privacy Filter RabbitMQ sizing described in [Queues](#queues).

Wait for the Privacy Filter pod to become ready before enabling AI Privacy Filter in the Lightrun Management Portal.

> [!IMPORTANT]
> The Helm setting and the organization setting have different effects. The Helm setting creates the infrastructure and incurs its cost. The organization setting controls whether new Dynamic Logs and Snapshots use that infrastructure. Turning off the organization setting does not stop the pod or remove the GPU node.

## Queues

The chart declares the queues; the service only checks that they exist.

| Queue | Default name | Purpose |
| ----- | ------------ | ------- |
| Request | `privacy-filter-requests` | Texts to redact. Messages expire after 1 hour. |
| Dead letter | `privacy-filter-requests.dlq` | Requests that can never succeed (kept 7 days). |
| Response | `privacy-filter-responses` | Redacted texts (kept 24 hours). |

Names and limits are under `general.mq.privacy_filter` in `values.yaml`.

While Privacy Filter is enabled, RabbitMQ uses larger resources (`general.mq.privacy_filter.rabbitmq`: 1 CPU, 4Gi memory, 10Gi storage) instead of the regular `deployments.rabbitmq` values, so bursts of large texts can queue up in the broker.

## Configuration

Settings are under **`deployments.privacy_filter`**.

```yaml
deployments:
  privacy_filter:
    replicas: 1
    image:
      repository: lightruncom/privacy-filter
      tag: ""
    resources:
      requests: { cpu: "2", memory: 5Gi }
      limits:   { cpu: "3", memory: 6Gi }
    nodeSelector: {}
    tolerations: []
```

Other options (`extraEnvs`, probes, security contexts, PDB, affinity, ...) work as for the other components.

### Default pod resources

The default chart requests 2 CPU and 5Gi of memory and limits the container to 3 CPU and 6Gi of memory. It also provides a 2Gi writable temporary volume. These settings do not represent the GPU or node cost.

| Resource | Default |
|---|---|
| Replicas | 1 |
| CPU request / limit | 2 / 3 |
| Memory request / limit | 5Gi / 6Gi |
| Temporary storage | 2Gi |
| GPU nodes | One dedicated node per replica |

### GPU node requirements

Run Privacy Filter on a dedicated GPU node. The pod sets `NVIDIA_VISIBLE_DEVICES=all` and `NVIDIA_DRIVER_CAPABILITIES=compute,utility`, but the default chart values do not request a Kubernetes `nvidia.com/gpu` resource or set a `RuntimeClass`.

Use `nodeSelector` and `tolerations` to prevent the pod from scheduling on a general-purpose CPU node:

```yaml
deployments:
  privacy_filter:
    nodeSelector:
      workload: privacy-filter
    tolerations:
      - key: workload
        operator: Equal
        value: privacy-filter
        effect: NoSchedule
```

Verify that the selected node has the NVIDIA driver and container runtime configured before installing the chart. If the node is absent or incompatible, the pod can remain pending or fail its startup probe.

The default resources suit a dedicated node as small as AWS `g6f.2xlarge` (8 vCPU, 32 GiB, and a quarter of an L4 GPU). This is an AWS-specific example rather than a portable minimum; select an equivalent instance based on your Kubernetes platform and region.

> [!IMPORTANT]
> On a fractional GPU such as `g6f`, set `OPF_GPU_MEMORY_UTILIZATION` to `"0.75"`; the default `0.9` does not fit.
> ```yaml
> deployments:
>   privacy_filter:
>     extraEnvs:
>       - name: OPF_GPU_MEMORY_UTILIZATION
>         value: "0.75"
> ```

### Tuning

The service reads `OPF_*` environment variables, set through `extraEnvs`. Start with the defaults; these are the ones worth changing:

| Setting | Description |
| ------- | ----------- |
| `rabbitmq.prefetch` | Raise it if the GPU is idle while the queue has a backlog. |
| `OPF_GPU_MEMORY_UTILIZATION` | Share of GPU memory vLLM may use (default `0.9`). |
| `OPF_MAX_BATCHED_TOKENS`, `OPF_MAX_NUM_SEQS` | GPU batch size. Lower them if the GPU runs out of memory. |
| `OPF_MAX_PENDING_TOKENIZE_CHARS` | Characters being tokenized at once (default 20M); the main driver of host memory. |

To process more, add replicas: they consume from the same queue, one GPU node each.

## Startup

The pod waits for RabbitMQ (`wait-for-rabbitmq` init container), then loads the model, which is embedded in the image and takes a few minutes. The pod becomes ready once it is consuming from the request queue.

## Verify the deployment

Before enabling the organization setting:

1. Confirm that the Privacy Filter pod is running and ready.

    ```shell
    kubectl get pods -n <namespace>
    ```

2. Review the deployment logs and confirm that the model loaded and the service is consuming from RabbitMQ.

    ```shell
    kubectl logs deployment/<release>-privacy-filter -n <namespace>
    ```

3. Confirm that the `privacy-filter-requests`, `privacy-filter-responses`, and `privacy-filter-requests.dlq` queues exist.
4. After enabling the organization setting, test a Dynamic Log and a Snapshot containing test PII. Confirm that detected values appear as `<REDACTED>`.

## Disable Privacy Filter

To avoid rejecting action data while the infrastructure is unavailable:

1. Turn off **AI Privacy Filter** in the Lightrun Management Portal.
2. Allow pending requests to complete and confirm that the Privacy Filter queues have drained.
3. Set `general.privacy_filter.enabled` to `false` and upgrade the Helm release.
4. Remove the dedicated GPU node or its auto-provisioning configuration if no other workload uses it.

Disabling the chart removes the Privacy Filter deployment, stops configuring the backend to publish redaction requests, and returns RabbitMQ to the resources configured under `deployments.rabbitmq`. Existing queues can require separate cleanup, and a statically provisioned GPU node is not removed automatically.
