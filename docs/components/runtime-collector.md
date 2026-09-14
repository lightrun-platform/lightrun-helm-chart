# Runtime Collector

The **Runtime Collector** is an optional component that collects runtime intelligence data for Lightrun. Configuration is split into three sections:

- **`runtime_collector.enabled`**: Enables or disables the component.
- **`runtime_collector.server`**: Deployment settings for the runtime-collector application (image, scaling, probes, and service).
- **`runtime_collector.clickhouse`**: ClickHouse connection settings. ClickHouse can be deployed [**locally**](#local-clickhouse-runtime_collectorclickhouselocalenabled-true) with the chart or connected as an [**external**](#external-clickhouse-runtime_collectorclickhouselocalenabled-false) instance.

> [!NOTE]
> Runtime Collector is **disabled by default** (`runtime_collector.enabled: false`).

## Enable Runtime Collector

```yaml
runtime_collector:
  enabled: true
```

## Credentials

Runtime Collector uses two secrets: a gRPC shared secret between it and the backend, and ClickHouse credentials. See [Managing Secrets](../installation/secrets.md#mandatory-secret-fields) for how secrets are created or pre-provisioned, and which fields each one needs.

```yaml
secrets:
  runtime_collector:
    grpc_secret: ""
  clickhouse:
    user: ""      # only used with local ClickHouse
    password: ""  # only used with local ClickHouse
```

For external ClickHouse, credentials are set under `runtime_collector.clickhouse.external` instead — see [External ClickHouse](#external-clickhouse-runtime_collectorclickhouselocalenabled-false) below.

---

## External ClickHouse (`runtime_collector.clickhouse.local.enabled: false`)

In this mode, ClickHouse is **not deployed inside the cluster**. The runtime-collector connects to an existing ClickHouse instance.

```yaml
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

---

## Local ClickHouse (`runtime_collector.clickhouse.local.enabled: true`)

In this mode, the chart deploys a single-replica ClickHouse pod in the cluster and connects runtime-collector to it. With `general.internal_tls.enabled: true`, this connection uses TLS like any other internal chart connection — see [Internal TLS](#internal-tls) below.

```yaml
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
          memory: 1Gi
        limits:
          cpu: 500m
          memory: 1Gi
      persistence:
        enabled: false
        existingClaim: ""
      emptyDir:
        sizeLimit: 10Gi
```

> [!NOTE]
> - Local ClickHouse runs with a **fixed replica count of 1** (no PDB or topology spread) and always uses the `Recreate` rollout strategy.
> - When `persistence.enabled: false`, data is stored in an **EmptyDir** volume and is lost when the pod is replaced.
> - When `persistence.enabled: true`, the chart mounts the claim named in `existingClaim`. As with the other persistent volumes in this chart, you create and manage the PVC yourself, so its lifecycle is independent of the release. A `ReadWriteOnce` claim is enough for the single replica.
> - Clustered ClickHouse is only supported for external instances, via `clickhouse.external.cluster`.
> - When `general.readOnlyRootFilesystem: true`, an EmptyDir is mounted at `/etc/clickhouse-server/users.d` so the entrypoint can rewrite `default-user.xml`.

## Runtime Collector Server (`runtime_collector.server`)

Configuration for the runtime-collector application deployment.

The pod runs two init containers before the application starts:

| Init container | Purpose |
| -------------- | ------- |
| **`wait-for-clickhouse`** | Polls the ClickHouse HTTP `/ping` endpoint until it responds. Image is configurable under `server.initContainers.wait_for_clickhouse`. |
| **`migrate-clickhouse`** | Creates the database if it does not exist and applies the schema migrations. Image repository is configurable under `server.initContainers.migrations`; its tag always follows `server.image.tag`, because the two images are released together. |

## Internal TLS

When `general.internal_tls.enabled` is `true`, runtime-collector and local ClickHouse use TLS for internal communication like any other chart component — no extra opt-in is required. See [Internal TLS](../advanced/internal_tls.md) for the general mechanism (certificate sources, verification).

With `source: existing_certificates`, provide a secret for each of the two services:

```yaml
general:
  internal_tls:
    enabled: true
    certificates:
      source: existing_certificates
      existing_certificates:
        runtime_collector: ""
        runtime_collector_clickhouse: ""
        backend: ""
```

> [!IMPORTANT]
> With `source: generate_self_signed_certificates`, neither side of the backend<->runtime-collector gRPC connection trusts the other's generated certificate — set `certificates.verification: false`, or use `existing_certificates` with a real shared CA, for either direction to work.

---

## Database Name

```yaml
runtime_collector:
  clickhouse:
    database: runtime_collector
```

The `migrate-clickhouse` init container creates this database if it does not already exist, then
applies the migrations to it. For external ClickHouse, the configured credentials therefore need
permission to create a database, unless you create it yourself beforehand.
