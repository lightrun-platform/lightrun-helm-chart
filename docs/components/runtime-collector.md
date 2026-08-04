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

ClickHouse does not mount a CA — it only serves TLS and does not call other services. The CA is mounted on the **runtime-collector deployment** only (wait and migrate init containers, and the main container) so those clients can verify the ClickHouse server certificate when connecting. Wherever it is mounted, `SSL_CERT_FILE` points at it.

> [!IMPORTANT]
> `certificates.verification` has **no effect on the ClickHouse connection**. The collector uses ClickHouse `client-v2` 0.9.8, which provides no way to disable certificate verification — the `setSSLMode` escape hatch first appears in `0.10.0`, which is still pre-release ([#2309](https://github.com/ClickHouse/clickhouse-java/issues/2309), [#2389](https://github.com/ClickHouse/clickhouse-java/issues/2389)). The certificate is therefore always verified, and a CA is always mounted so that verification can succeed. Setting `verification: false` does not turn it off. This will be revisited when `0.10.0` reaches GA.

**Local ClickHouse** — a CA is always mounted, so TLS works with either certificate source:

| `certificates.source` | `existing_ca_secret_name` | CA that is mounted |
| --------------------- | ------------------------- | ------------------ |
| `generate_self_signed_certificates` | any | The CA generated by the release (`<release>-internal-tls-ca`, `custom-ca.pem` key) — the same one Keycloak trusts. It signed the certificates, so it is the only CA that can verify them |
| `existing_certificates` | set | `existing_ca_secret_name` (`ca.crt` key) |
| `existing_certificates` | empty | None available — **rejected at install time**, since the certificate can be neither verified nor accepted unverified |

**External ClickHouse** — set `clickhouse.external.existing_ca_secret_name` and it is mounted the same way, regardless of `verification`. If it is left empty, the certificate is validated against the system trust store, which is correct for a publicly trusted endpoint such as ClickHouse Cloud, unless `verification: false` is also set, in which case verification is skipped. This is the one remaining case where `verification` still changes anything, because there is no CA to trust.

> [!NOTE]
> `SSL_CERT_FILE` **replaces** the system trust store rather than adding to it. Only set `existing_ca_secret_name` for an endpoint whose certificate that CA actually signed — pointing it at an unrelated CA makes an otherwise publicly trusted endpoint fail verification. To trust both, the secret must hold the private CA concatenated with the public bundle.

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
