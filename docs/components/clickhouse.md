# ClickHouse

ClickHouse is the storage layer of the [Runtime Collector](runtime-collector.md), where the runtime intelligence data it collects is stored. It can be deployed as a [**Local ClickHouse**](#local-clickhouse) with the chart or used as an [**External ClickHouse**](#external-clickhouse). This is controlled by the settings under `deployments.runtime_collector.clickhouse` in `values.yaml`.

ClickHouse is only used when Runtime Collector is enabled (`deployments.runtime_collector.enabled: true`).

There are two modes:

- **Local ClickHouse Deployment** (`deployments.runtime_collector.clickhouse.local.enabled: true`): The chart deploys a single-replica ClickHouse instance inside the cluster.
- **External ClickHouse Deployment** (`deployments.runtime_collector.clickhouse.local.enabled: false`): The chart connects to an externally managed ClickHouse instance, such as ClickHouse Cloud or a cluster managed by a ClickHouse Kubernetes operator.

> [!TIP]
> We recommend using an **External ClickHouse**. Options are:
> - Managed [ClickHouse Cloud](https://clickhouse.com/cloud)
> - A ClickHouse Operator (see [Integrating Lightrun with a ClickHouse Kubernetes Operator](../advanced/clickhouse-operator-integration.md))
> - A ClickHouse Helm chart
> - Any other managed ClickHouse solution
>
> Alternatively (**not recommended**), you can use the [Local ClickHouse](#local-clickhouse) deployed by this chart, with the understanding that it is a **single replica** and that **you are in charge of its backups and restores**.

> [!NOTE]
> When using external ClickHouse, ensure that the provided host is reachable from the runtime-collector pod on both the HTTP/HTTPS and the native ports.

> [!IMPORTANT]
> - Supported ClickHouse version: 25.3 or later
> - Minimum size requirements: 2 vCPU, 8GB memory. Size the disk according to the planned data retention and coordinate it with a Lightrun support engineer.
> - Supported HA configurations: replicated ClickHouse (ClickHouse Cloud or an operator-managed cluster) through `external.cluster`. Local ClickHouse is single-replica only.

### Configuration Options

#### General Settings
```yaml
deployments:
  runtime_collector:
    clickhouse:
      database: runtime_collector
```

The `migrate-clickhouse` init container creates this database if it does not already exist, then applies the migrations to it. For external ClickHouse, the configured credentials therefore need permission to create a database, unless you create it yourself beforehand.

---
#### External ClickHouse

To use an external ClickHouse instance, set `clickhouse.local.enabled` to `false`. In this mode, the chart will not deploy a local ClickHouse pod but will connect to an existing ClickHouse.

- **Single Node:**
```yaml
deployments:
  runtime_collector:
    clickhouse:
      local:
        enabled: false
      external:
        host: "clickhouse.example.com"
        httpPort: 8123
        nativePort: 9000
        tls: false
        verify: true
        existing_ca_secret_name: ""
        username: ""
        password: ""
        existingSecret: ""
```
- **Replicated / Clustered (ClickHouse Cloud or operator-managed cluster):**
```yaml
deployments:
  runtime_collector:
    clickhouse:
      local:
        enabled: false
      external:
        host: "abc123.us-east-1.aws.clickhouse.cloud"
        httpPort: 8443
        nativePort: 9440
        tls: true
        cluster: "default"
        existingSecret: "clickhouse-credentials"
```

| Property | Description |
| -------- | ----------- |
| **`external.host`** | ClickHouse hostname or FQDN. |
| **`external.httpPort`** | HTTP interface port (default: `8123`). |
| **`external.nativePort`** | Native protocol port (default: `9000`). |
| **`external.tls`** | Set to `true` when the external ClickHouse endpoint uses TLS. |
| **`external.verify`** | Verify the server certificate when `tls: true` (default `true`). Independent of `general.internal_tls.certificates.verification`. |
| **`external.existing_ca_secret_name`** | Kubernetes secret with the CA certificate (`ca.crt` key), used to verify the ClickHouse server certificate. Only set this for an endpoint whose certificate that CA actually signed — for a publicly trusted endpoint (e.g. ClickHouse Cloud), leave it empty so the system trust store is used instead. |
| **`external.cluster`** | ClickHouse cluster name, for clustered external deployments (ClickHouse Cloud, or an operator-managed cluster). When set, the database and the migrations table are created `ON CLUSTER`. Leave empty for a single-node instance. |
| **`external.username` / `external.password`** | Inline ClickHouse credentials. Ignored if `existingSecret` is set. |
| **`external.existingSecret`** | Name of an existing secret with `CLICKHOUSE_USERNAME` and `CLICKHOUSE_PASSWORD` keys, instead of the inline credentials above. |

> [!IMPORTANT]
> - When using external ClickHouse, local deployment settings (image, resources, persistence, health probes, etc.) do not apply.
> - Credentials for external ClickHouse are set under `deployments.runtime_collector.clickhouse.external`, not under `secrets.clickhouse`.
> - For instructions on installing ClickHouse with a Kubernetes operator, see [Integrating Lightrun with a ClickHouse Kubernetes Operator](../advanced/clickhouse-operator-integration.md).

---
#### Local ClickHouse

When using a local ClickHouse deployment (i.e., `deployments.runtime_collector.clickhouse.local.enabled: true`), the chart deploys a local ClickHouse instance with the following characteristics:

- **Single Replica Only**: The local deployment always uses one replica (no PDB or topology spread) and the `Recreate` rollout strategy. Clustered ClickHouse is only supported for external instances.
- **Backups and Restores Are Your Responsibility**: The chart does not back up local ClickHouse data.
- All deployment settings (image, resources, persistence, and health probes) apply.
- Credentials are taken from `secrets.clickhouse.user` and `secrets.clickhouse.password`. See [Managing Secrets](../installation/secrets.md).

Configuration is defined under **`deployments.runtime_collector.clickhouse.local`** in the **`values.yaml`** file.

```yaml
deployments:
  runtime_collector:
    clickhouse:
      local:
        enabled: true
        httpPort: 8123
        nativePort: 9000
        image:
          repository: clickhouse/clickhouse-server
          tag: "25.3-alpine"
          pullPolicy: IfNotPresent
        resources:
          requests:
            cpu: 500m
            memory: 4Gi
          limits:
            cpu: 500m
            memory: 4Gi
        persistence:
          enabled: false
          existingClaim: ""
        emptyDir:
          sizeLimit: 10Gi
```

##### Option 1: Persistent Storage (**Recommended**)

```yaml
deployments:
  runtime_collector:
    clickhouse:
      local:
        persistence:
          enabled: true
          existingClaim: "clickhouse-data"
```

- The chart mounts the claim named in `existingClaim`. As with the other persistent volumes in this chart, you create and manage the PVC yourself, so its lifecycle is independent of the release.
- A `ReadWriteOnce` claim is enough for the single replica.
- Size the PVC according to the planned data retention.

##### Option 2: Ephemeral Storage (default)

> **⚠️ Recommended for testing only!**

- Uses an **EmptyDir** volume (`emptyDir.sizeLimit`, default `10Gi`).
- **Data is lost** when the pod is replaced, and the pod is evicted when the volume exceeds its size limit.

> [!NOTE]
> - When `general.readOnlyRootFilesystem: true`, an EmptyDir is mounted at `/etc/clickhouse-server/users.d` so the entrypoint can rewrite `default-user.xml`.
> - With `general.internal_tls.enabled: true`, the connection to local ClickHouse uses TLS like any other internal chart connection. See [Runtime Collector — Internal TLS](runtime-collector.md#internal-tls).
