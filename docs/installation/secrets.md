## **Overview**

Lightrun requires various secrets for authentication, database access, message queues, and integrations. These secrets are managed under `secrets` and can either be deployed as part of this chart or managed externally.
### **Managing Secrets Deployment**

- If `deploy_secrets: true`, the Helm chart will create and manage secrets.
- If `deploy_secrets: false`, secrets **must be pre-created** in Kubernetes. The chart will look for an existing secret named:
```go
{{ .Release.name }}-backend
```
* To use a **custom secret name**, set:
```yaml
general:
  deploy_secrets:
    existing_secrets:
      backend: ""
      keycloak: ""
```
- _(This is relevant only when `deploy_secrets: false`.)_
> [!WARNING]
> If managing secrets externally, ensure all required fields are present. See the [secrets template](https://github.com/lightrun-platform/lightrun-helm-chart/blob/main/chart/templates/secrets.yaml#L31) for reference.

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

  redis:
    password: ""  # Redis authentication password

```
> **Note**: Redis authentication requires `deployments.redis.auth.enabled: true`.

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
    hubspot_token: ""    # (Optional) Token for HubSpot integration

```
> **Optional Fields**: If left empty, these values **will not** be included in the Kubernetes secret.

### **Container Image Registry Credentials**

```yaml
  dockerhub_config:
    existingSecret: ""  # Use an existing secret if provided
    configContent: ""   # Create a new secret if `existingSecret` is empty
```
Refer to [Container Image Registry Overview](container_image_registry.md) for a detailed explanation how to configure dockerhub_config.