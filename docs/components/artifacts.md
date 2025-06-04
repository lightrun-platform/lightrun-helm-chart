### Overview

The **Artifacts** service is an nginx-based proxy that serves Lightrun artifacts. This service acts as an internal artifact repository for the backend server. The service supports both HTTP and HTTPS protocols depending on the internal TLS configuration.

Configuration is defined under **`deployments.artifacts`** in the **`values.yaml`**

### Configuration Options

#### Logging Configuration

```yaml
artifacts:
  loglevel: notice          # Nginx log level (emerg, alert, crit, error, warn, notice, info, debug)
  useJsonLogFormat: false   # Enables structured JSON logging
```

#### Replicas

```yaml
  replicas: 1              # Number of replicas to run
```

#### Deployment Strategy

```yaml
  rollout_strategy: "RollingUpdate"  # Defines the rollout strategy
```

#### Image Configuration

```yaml
  image:
    repository: lightruncom/artifacts  # Docker image repository
    tag: ""
    pullPolicy: IfNotPresent          # Image pull policy
```

#### Resource Allocation

```yaml
  resources:
    cpu: 500m      # CPU limit and request
    memory: 128Mi  # Memory limit and request
```

#### Pod Labels & Annotations

```yaml
  podLabels: {}
  podAnnotations: {}
  annotations: {}  # Deployment annotations
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

#### Pod Disruption Budget & Scheduling

```yaml
  podDisruptionBudget: {}  # [minAvailable|maxUnavailable] either integer or percentage
  topologySpreadConstraints: []
  affinity: {}
```

#### Health Probes

```yaml
  livenessProbe: 
    initialDelaySeconds: 10
    periodSeconds: 20
    timeoutSeconds: 10
    successThreshold: 1
    failureThreshold: 3
    path: /health

  readinessProbe:
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 3
    path: /health
```