# Privacy Filter

The **Privacy Filter** is an optional service that redacts personal data (PII) from text before Lightrun stores it. It runs an AI model (`openai/privacy-filter`) on a GPU and replaces private values with placeholders, e.g. `Email <PRIVATE_EMAIL>`.

When enabled, the backend sends it the texts of **snapshots** and **logs** collected from agents, and stores only the redacted result.

> [!NOTE]
> Privacy Filter is **disabled by default** and **requires RabbitMQ** (`general.mq.enabled: true`). It needs an NVIDIA GPU node.

## How it works

```
Agent ──► Backend ──► [privacy-filter-requests] ──► Privacy Filter
                                                          │
Backend (stores redacted data) ◄── [privacy-filter-responses]
```

1. The backend publishes the texts to redact to the request queue (in chunks of up to 1000 texts).
2. A Privacy Filter pod consumes them, runs the model and publishes the redacted texts, in the same order, to the response queue. Replies carry the request's `correlation_id` and an opaque context, so neither side keeps per-request state.
3. The backend consumes the reply and stores the data. A snapshot waits as a pending record, holding no personal data, until all its texts are back.

Privacy Filter has no inbound traffic and **no Kubernetes Service**: it only connects out to RabbitMQ. Its HTTP port (`8786`) serves just the `/health` and `/ready` probes.

### Failure behavior

Nothing is ever stored unredacted.

| Situation | Result |
| --------- | ------ |
| Transient failure in the service (engine error, timeout) | Retried up to `rabbitmq.max_attempts` times. |
| Request can never succeed (invalid, too large) or retries exhausted | Error reply; the request moves to `<request queue>.dlq`. The backend stores the text as `<REDACTION_FAILED>`. |
| Request can't be queued (queue full, RabbitMQ down) | The agent's data is rejected with a `Retry-After`, so the agent retries. |
| No reply for a snapshot (e.g. request expired in RabbitMQ) | After ~65 minutes the snapshot is stored with the missing texts marked `<REDACTION_FAILED>`. |

## Enable Privacy Filter

```yaml
general:
  mq:
    enabled: true
  privacy_filter:
    enabled: true
```

This deploys the Privacy Filter pod, creates its queues and tells the backend and crons to use it.

> [!NOTE]
> The chart enables the infrastructure. Whether a company's data is actually filtered is controlled in the Lightrun server: the feature must be rolled out and the company must opt in.

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
      requests: { cpu: "3", memory: 8Gi }
      limits:   { cpu: "4", memory: 12Gi }
    nodeSelector: {}
    tolerations: []
```

Other options (`extraEnvs`, probes, security contexts, PDB, affinity, ...) work as for the other components.

### GPU node

Run Privacy Filter on its own GPU node: it runs one container per GPU and uses the whole node. The pod sets `NVIDIA_VISIBLE_DEVICES=all` and `NVIDIA_DRIVER_CAPABILITIES=compute,utility`, so on a node with the NVIDIA container runtime no GPU resource request or `RuntimeClass` is needed. Select the node and tolerate its taint through `nodeSelector` and `tolerations`, for example:

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

The default resources suit a dedicated node as small as AWS `g6f.2xlarge` (8 vCPU, 32 GiB, a quarter of an L4 GPU).

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
