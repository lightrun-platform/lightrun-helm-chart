### Overview

The keycloak service provides the authentication. It is deployed as a Kubernetes pod and can be configured for scaling, resource allocation, and health monitoring.
configuration is defined under **`deployments.keycloak`** in the **`values.yaml`**
### Configuration Options

#### General Settings

```yaml
  useJsonLogFormat: false  # Enables structured JSON logging
  clusterMode: true 
```

#### Horizontal Pod Autoscaling (HPA) And Replicas

```yaml
  hpa:
    enabled: false          # Enables or disables HPA
    cpu: 70                # Target CPU utilization percentage
    maxReplicas: 5         # Maximum number of replicas
  replicas: 1              # Default number of replicas
```

#### Deployment Strategy

```yaml
  rollout_strategy: "Recreate"  # Defines the rollout strategy
```

#### Image Configuration

```yaml
  image:
    repository: lightruncom/keycloak
    tag: ""
    pullPolicy: IfNotPresent
```

#### Resource Allocation

```yaml
  resources:
    cpu: 1000m       # CPU limit
    memory: 2Gi   # Memory limit
```

#### Pod Labels & Annotations

```yaml
  podLabels: {}
  podAnnotations: {}
  annotations: {}  # Deprecated in favor of podAnnotations
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
  cluster_cert:
    image:
      repository: lightruncom/chart-helper
      tag: latest
      pullPolicy: ""
```
> **Note:** The `cluster_cert` init container is used only with internal_tls and keycloak cluster mode.

#### Pod Disruption Budget & Scheduling

```yaml
  podDisruptionBudget: {}
  topologySpreadConstraints: []
  affinity: {}
```

#### Health Probes

```yaml
startupProbe:
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 1
  successThreshold: 1
  failureThreshold: 30
livenessProbe:
  initialDelaySeconds: 200
  periodSeconds: 50
  timeoutSeconds: 30
  successThreshold: 1
  failureThreshold: 3
readinessProbe:
  initialDelaySeconds: 0
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
```