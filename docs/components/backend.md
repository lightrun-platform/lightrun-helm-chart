# Backend Service

The backend component is responsible for handling core application logic and interactions with the database, message queues, and other services. This document outlines the configurable parameters available for backend deployment.
configuration is defined under **`deployments.backend`** in the **`values.yaml`**
### Configuration Options

#### General Settings

```yaml
backend:
  useJsonLogFormat: false  # Enables structured JSON logging
```

#### Horizontal Pod Autoscaling (HPA) And Replicas

```yaml
  hpa:
    enabled: false          # Enables or disables HPA
    cpu: 50                # Target CPU utilization percentage
    maxReplicas: 5         # Maximum number of replicas
  replicas: 1              # Default number of replicas
```

#### Deployment Strategy

```yaml
  rollout_strategy: "Recreate"  # Defines the rollout strategy
```
> **Note:** The `rollout_strategy` should not be changed while upgrading Lightrun version.

#### Image Configuration

```yaml
  image:
    repository: lightruncom/server
    tag: ""
    pullPolicy: IfNotPresent
```

#### Resource Allocation

```yaml
  resources:
    cpu: 3000m    # CPU limit
    memory: 7Gi   # Memory limit
```

#### Pod Labels & Annotations

```yaml
  podLabels: {}
  podAnnotations: {}
  annotations: {}  # Deprecated in favor of podAnnotations
```

#### Langfuse MCP

All Langfuse settings are grouped under `general.langfuse` in `values.yaml`:

```yaml
general:
  langfuse:
    mcp:
      enabled: false
      otlp_endpoint: "https://us.cloud.langfuse.com/api/public/otel/v1/traces"
      public_key: ""
      secret_key: ""
```

Set `general.langfuse.mcp.enabled: true` to add the Langfuse environment variables to the backend Deployment. Credentials are referenced from the backend Secret. When disabled, the chart omits these environment entries and credentials from chart-managed secrets.

When enabled, the endpoint must be nonempty and is passed directly as `LANGFUSE_MCP_OTLP_ENDPOINT`, including when secrets are managed externally. Set it to a different URL to override the default. Helm validation rejects missing or whitespace-only endpoints.

Crons has no explicit Langfuse environment entries. Both deployments still load the shared backend Secret through `envFrom`, so any credentials present there are inherited regardless of this flag.

Configure credentials under `general.langfuse.mcp.public_key` and `general.langfuse.mcp.secret_key`; see [Managing Secrets](../installation/secrets.md).

#### Extra Environment Variables
```yaml
extraEnvs: []
```

The chart may also set `LIGHTRUN_SECURITY_PINNED_HASHES` when you define `certificate.security_pinned_hashes` (comma-separated SPKI SHA-256 hashes). See [Managing the TLS Certificate](../installation/certificate.md).

#### Security Contexts

```yaml
  podSecurityContext: {}
  containerSecurityContext: {}
```

#### Service Annotations & Labels

```yaml
  service:
    annotations: {}
    labels: {}
```

#### Volumes 

```yaml
  extraVolumes: []
  extraVolumeMounts: []

```

#### Init Containers
```yaml
  initContainers:
    wait_for_keycloak:
      image:
        repository: lightruncom/chart-helper
        tag: latest
        pullPolicy: ""
    p12_creator:
      image:
        repository: lightruncom/chart-helper
        tag: latest
        pullPolicy: ""
    wait_for_rabbitmq:
      image:
        repository: lightruncom/chart-helper
        tag: latest
        pullPolicy: ""
```
#### Pod Disruption Budget & Scheduling

```yaml
  podDisruptionBudget: {}
  topologySpreadConstraints: []
  affinity: {}
```

#### Lifecycle & Graceful Shutdown

```yaml
  lifecycle:
    preStop:
      exec:
        command: ["sh", "-c", "sleep 10"]
  terminationGracePeriodSeconds: 45
```

#### Health Probes

```yaml
  startupProbe:
    path: /management/health/readiness
    failureThreshold: 60
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1

  livenessProbe:
    initialDelaySeconds: 200
    periodSeconds: 50
    timeoutSeconds: 30
    successThreshold: 1
    failureThreshold: 3
    path: /version

  readinessProbe:
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 3
    path: /management/health/readiness
```
