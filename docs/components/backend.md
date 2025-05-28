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

#### Artifact Management

```yaml
  artifacts:
    enable: true
    repository_url: https://artifacts.lightrun.com/
    supported_versions_url: https://artifacts.lightrun.com/supported-versions.json
    resolution_mode: latest
```
#### Extra Environment Variables
```yaml
extraEnvs: []
```

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
