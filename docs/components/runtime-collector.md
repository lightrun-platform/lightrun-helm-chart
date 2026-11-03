# Runtime Collector

The **Runtime Collector** is an optional component that collects runtime intelligence data for Lightrun. Configuration is split into three sections:

- **`deployments.runtime_collector.enabled`**: Enables or disables the component.
- **`deployments.runtime_collector.server`**: Deployment settings for the runtime-collector application (image, scaling, probes, and service).
- **`deployments.runtime_collector.clickhouse`**: ClickHouse connection settings. ClickHouse can be deployed [**locally**](clickhouse.md#local-clickhouse) with the chart or connected as an [**external**](clickhouse.md#external-clickhouse) instance. See [ClickHouse](clickhouse.md).

> [!NOTE]
> Runtime Collector is **disabled by default** (`deployments.runtime_collector.enabled: false`).

## Enable Runtime Collector

```yaml
deployments:
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

For external ClickHouse, credentials are set under `runtime_collector.clickhouse.external` instead — see [External ClickHouse](clickhouse.md#external-clickhouse).

---

## ClickHouse

Runtime Collector stores its data in ClickHouse, either deployed locally by the chart or as an external instance. See [ClickHouse](clickhouse.md) for the supported versions, sizing, and the local and external configuration.

> [!TIP]
> We recommend using an **External ClickHouse**. Options are:
> - Managed [ClickHouse Cloud](https://clickhouse.com/cloud)
> - A ClickHouse Operator (see [Integrating Lightrun with a ClickHouse Kubernetes Operator](../advanced/clickhouse-operator-integration.md))
> - A ClickHouse Helm chart
> - Any other managed ClickHouse solution
>
> [Local ClickHouse](clickhouse.md#local-clickhouse) deployment is suitable for development or smaller installations. For production, verify that your resources and persistence settings meet your requirements.

## Runtime Collector Server (`runtime_collector.server`)

Configuration for the runtime-collector application deployment.

```yaml
deployments:
  runtime_collector:
    server:
      useJsonLogFormat: false  # Enables structured JSON logging
```

The pod runs these init containers before the application starts (`wait-for-rabbitmq` only when `general.mq.enabled: true`):

| Init container | Purpose |
| -------------- | ------- |
| **`wait-for-rabbitmq`** | Polls the RabbitMQ management API until it responds. Image is configurable under `server.initContainers.wait_for_rabbitmq`. |
| **`wait-for-clickhouse`** | Polls the ClickHouse HTTP `/ping` endpoint until it responds. Image is configurable under `server.initContainers.wait_for_clickhouse`. |
| **`migrate-clickhouse`** | Creates the database if it does not exist and applies the schema migrations. Image repository is configurable under `server.initContainers.migrations`; its tag always follows `server.image.tag`, because the two images are released together. |

> [!NOTE]
> `server.rollout_strategy` defaults to `Recreate`, not `RollingUpdate`: `migrate-clickhouse` can run schema migrations that break the previous server version, so the old and new pods must never run concurrently.

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
