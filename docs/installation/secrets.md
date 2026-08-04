# Managing Secrets

Lightrun requires various secrets for authentication, database access, message queues, and integrations. These secrets are managed under `secrets` and can either be deployed as part of this chart or managed externally.
### **Secrets Deployment Options**

- If `deploy_secrets: true`, the Helm chart will create and manage secrets.
- If `deploy_secrets: false`, secrets **must be pre-created** in Kubernetes. The chart will look for existing secrets:
  - **Backend secret:** `{{ .Release.name }}-backend`
  - **Keycloak secret:** `{{ .Release.name }}-keycloak`
  - **ClickHouse secret:** `{{ .Release.name }}-runtime-collector-clickhouse` (when Runtime Collector is enabled and not using `clickhouse.external.existingSecret`). This secret is also expected to exist when `deploy_secrets: true` but the ClickHouse credentials are empty in values.

To use **custom secret names**, set:
```yaml
general:
  deploy_secrets:
    existing_secrets:
      backend: ""
      keycloak: ""
      clickhouse: ""
```
Note that this is only relevant when `deploy_secrets: false`.

> [!WARNING]
> When managing secrets externally, ensure all required fields are present in both the backend and Keycloak secrets. See the [secrets template](https://github.com/lightrun-platform/lightrun-helm-chart/blob/main/chart/templates/secrets.yaml#L31) for reference.

- _(This is relevant only when `deploy_secrets: false`.)_

### **Mandatory Secret Fields**

When managing secrets externally, ensure the following fields are present in each secret (See the [secrets template](https://github.com/lightrun-platform/lightrun-helm-chart/blob/main/chart/templates/secrets.yaml#L31) for reference).

#### **Backend secret** (`{{ .Release.name }}-backend`)

| Environment Variable | Description | Value Source |
|---------------------|-------------|--------------|
| `SPRING_SECURITY_KEYCLOAK_CLI_PASSWORD` | Keycloak admin password | `secrets.keycloak.password` |
| `SPRING_MAIL_PASSWORD` | Mail server password | `secrets.defaults.mail_password` |
| `SPRING_FLYWAY_PASSWORD` | DB password | `secrets.db.password` |
| `SPRING_FLYWAY_USER` | DB user | `secrets.db.user` |
| `SPRING_DATASOURCE_USERNAME` | DB username | `secrets.db.user` |
| `SPRING_DATASOURCE_PASSWORD` | DB password | `secrets.db.password` |
| `KEYSTORE_PASSWORD` | Java Keystore password | `secrets.defaults.keystore_password` |
| `LICENSE_CONTENT` | Lightrun license content | `secrets.license.content` |
| `LICENSE_SIGNATURE` | Lightrun license signature | `secrets.license.signature` |
| `SPRING_RABBITMQ_USERNAME` | RabbitMQ username | `secrets.mq.user` |
| `SPRING_RABBITMQ_PASSWORD` | RabbitMQ password | `secrets.mq.password` |
| `encryption-key-0` | Backend encryption key (default) | `secrets.keysEncryption.userEncryptionKey` |

#### **Keycloak secret** (`{{ .Release.name }}-keycloak`)

| Secret Key | Description | Value Source |
|------------|-------------|--------------|
| `DB_PASSWORD` | Database password for Keycloak | `secrets.db.password` |
| `DB_USER` | Database username for Keycloak | `secrets.db.user` |
| `KEYCLOAK_PASSWORD` | Keycloak admin password | `secrets.keycloak.password` |
| `KEYCLOAK_USER` | Keycloak admin username | Fixed as `admin` in chart template; set same value when using external secret |

#### **ClickHouse secret** (`{{ .Release.name }}-runtime-collector-clickhouse`)

Required when [Runtime Collector](../components/runtime-collector.md) is enabled and credentials are not supplied via `runtime_collector.clickhouse.external.existingSecret`.

Note that this secret is also expected to be pre-created when `deploy_secrets: true` but the relevant credentials are left empty in values, which is the recommended way to keep ClickHouse credentials out of your values file.

| Secret Key | Description | Value Source |
|------------|-------------|--------------|
| `CLICKHOUSE_PASSWORD` | ClickHouse password | `secrets.clickhouse.password` (local) or `runtime_collector.clickhouse.external.password` (external) |
| `CLICKHOUSE_USERNAME` | ClickHouse username | `secrets.clickhouse.user` (local) or `runtime_collector.clickhouse.external.username` (external) |

> [!WARNING]
> For encryption keys, it's strongly recommended to provide them as external secrets rather than letting the chart manage them. See [Encryption Keys Documentation](../advanced/encryption_keys.md) for details.

## **Secrets Configuration**
### **Authentication and Access Secrets**

These secrets store authentication credentials for essential services.
```yaml
secrets:
  keycloak:
    password: ""  # Keycloak admin password

  db:
    user: ""      # Database username
    password: ""  # Database password

  mq:
    user: ""      # Message queue username
    password: ""  # Message queue password

  clickhouse:
    user: ""      # ClickHouse username (used when Runtime Collector is enabled)
    password: ""  # ClickHouse password (used when Runtime Collector is enabled)

  redis:
    password: ""  # Redis authentication password

```
> **Note**: Redis authentication requires `deployments.redis.auth.enabled: true`.
> **Note**: ClickHouse credentials apply when [Runtime Collector](../components/runtime-collector.md) is enabled with local ClickHouse.

### **License**

Lightrun requires specific secrets for licensing. 
```yaml
  license:
    content: ""    # Lightrun license file content
    signature: ""  # License signature
```
### **Integration and Default Credentials**

Some secrets are used for integrating with external services.
```yaml
  defaults:
    mail_password: ""  # Password for mail server authentication
    keystore_password: ""  # Java Keystore password

    google_sso:
      client_id: ""      # (Optional) Google SSO Client ID
      client_secret: ""  # (Optional) Google SSO Client Secret

    datadog_api_key: ""  # (Optional) API key for Datadog integration
    mixpanel_token: ""   # (Optional) Token for Mixpanel analytics

```
> **Optional fields**: If left empty, these values **will not** be included in the Kubernetes secret.

### **Container Image Registry Credentials**

```yaml
  dockerhub_config:
    existingSecret: ""  # Use an existing secret if provided
    configContent: ""   # Create a new secret if `existingSecret` is empty
```
Refer to [Container Image Registry Overview](container_image_registry.md) for a detailed explanation of how to configure `dockerhub_config`.
