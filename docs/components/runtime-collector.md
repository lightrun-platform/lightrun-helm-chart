# Runtime Collector

The **Runtime Collector** is an optional component that collects runtime intelligence data for Lightrun. When enabled, the chart deploys the runtime-collector service.

Configuration is split into three sections:

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

When enabled, the backend receives:

```yaml
RUNTIME_COLLECTOR_ENDPOINT: "<release>-runtime-collector:9090"
```

## ClickHouse Credentials

For **local ClickHouse**, credentials are stored in a dedicated ClickHouse secret:

- If `deploy_secrets: true` **and both `secrets.clickhouse.user` and `secrets.clickhouse.password` are set**, the chart creates `{{ .Release.name }}-runtime-collector-clickhouse`.
- If either field is left empty, the chart does **not** create the secret and expects it to already exist, even when `deploy_secrets: true`. This is the recommended way to keep ClickHouse credentials out of your values file.
- If `deploy_secrets: false`, the secret must always be pre-created.
- In every mode, `general.deploy_secrets.existing_secrets.clickhouse` overrides the expected secret name.

A pre-created secret must contain `CLICKHOUSE_USERNAME` and `CLICKHOUSE_PASSWORD`.

```yaml
secrets:
  clickhouse:
    user: ""
    password: ""
```

For **external ClickHouse**, provide credentials inline or via an existing secret:

```yaml
runtime_collector:
  clickhouse:
    external:
      username: ""
      password: ""
      existingSecret: ""  # If set, ignores inline username / password
```

> [!NOTE]
> When using external ClickHouse with `existingSecret`, the chart does not create a ClickHouse credentials secret. For local ClickHouse or external inline credentials with `deploy_secrets: true`, the chart creates `{{ .Release.name }}-runtime-collector-clickhouse`.

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
| **`external.tls`** | Set to `true` when the external ClickHouse endpoint uses TLS. Without a CA mount, connections skip certificate verification (`skip_verify`). |
| **`external.existing_ca_secret_name`** | Kubernetes secret with the CA certificate (`ca.crt` key). When set with `tls: true`, mounted automatically and `SSL_CERT_FILE` is set on runtime-collector and migrate init containers. |
| **`external.cluster`** | ClickHouse cluster name, for clustered external deployments (ClickHouse Cloud, or an operator-managed cluster). When set, the database and the migrations table are created `ON CLUSTER`. Leave empty for a single-node instance. |

> [!NOTE]
> **Local ClickHouse** with `general.internal_tls.enabled: true` uses TLS when service certificates are configured (see [Internal TLS](#internal-tls)). CA verification follows the same rules as backend and other services.

---

## Local ClickHouse (`runtime_collector.clickhouse.local.enabled: true`)

In this mode, the chart deploys a single-replica ClickHouse pod in the cluster and connects runtime-collector to it.

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
> - When `general.readOnlyRootFilesystem: true`, an init container copies `/etc/clickhouse-server` into a writable volume, because the ClickHouse entrypoint renders its user configuration there on every start.

## Runtime Collector Server (`runtime_collector.server`)

Configuration for the runtime-collector application deployment.

The pod runs two init containers before the application starts:

| Init container | Purpose |
| -------------- | ------- |
| **`wait-for-clickhouse`** | Polls the ClickHouse HTTP `/ping` endpoint until it responds. Image is configurable under `server.initContainers.wait_for_clickhouse`. |
| **`migrate-clickhouse`** | Creates the database if it does not exist and applies the schema migrations. Image repository is configurable under `server.initContainers.migrations`; its tag always follows `server.image.tag`, because the two images are released together. |

## Internal TLS

When `general.internal_tls.enabled` is `true`, runtime-collector and local ClickHouse use TLS for internal communication, exactly like the other chart components — no extra opt-in is required.

With `source: generate_self_signed_certificates` the chart generates the certificates for both services automatically. With `source: existing_certificates` you must provide a secret per service, otherwise those two services fall back to plaintext:

```yaml
general:
  internal_tls:
    enabled: true
    certificates:
      source: existing_certificates
      existing_certificates:
        runtime_collector: ""
        runtime_collector_clickhouse: ""
```

### CA Trust Behavior (Runtime Collector)

ClickHouse does not mount a CA — it only serves TLS and does not call other services. The CA is mounted on the **runtime-collector deployment** only (migrate init container and main container) so those clients can verify the ClickHouse server certificate when connecting.

Same rules as backend and other chart clients:

| `verification` | `existing_ca_secret_name` | Behaviour |
| -------------- | ------------------------- | --------- |
| `false` | any | No CA mount; connections skip certificate verification |
| `true` | set | Mounts `existing_ca_secret_name` (`ca.crt` key) on migrate + runtime-collector containers and points `SSL_CERT_FILE` at it, so both the application and the Go `migrate` binary trust that CA |
| `true` | empty | No CA mount, and verification is **not** skipped: the certificate is validated against the system trust store. Rejected at install time for local ClickHouse, whose certificate can never be publicly trusted. |

With `source: generate_self_signed_certificates`, **`verification` must be `false`**. The chart fails the install if runtime-collector uses local ClickHouse with internal TLS and `verification: true` in this mode.

For **external ClickHouse**, use `clickhouse.external.existing_ca_secret_name` — mounted the same way on migrate + runtime-collector containers only.

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
