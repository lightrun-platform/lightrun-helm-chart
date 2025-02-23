### Overview

The frontend service provides the user interface and interacts with backend services. It is deployed as a Kubernetes pod and can be configured for scaling, resource allocation, and health monitoring.

### Configuration Options

#### General Settings

```yaml
frontend:
  useJsonLogFormat: false  # Enables structured JSON logging
```

#### Horizontal Pod Autoscaling (HPA) And Replicas

```yaml
  hpa:
    enabled: false          # Enables or disables HPA
    cpu: 70                # Target CPU utilization percentage
    maxReplicas: 5         # Maximum number of replicas
  replicas: 1              # Default number of replicas
```

#### Image Configuration

```yaml
  image:
    repository: lightruncom/webapp
    tag: ""
    pullPolicy: IfNotPresent
```

#### Resource Allocation

```yaml
  resources:
    cpu: 100m       # CPU limit
    memory: 128Mi   # Memory limit
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

#### Pod Disruption Budget & Scheduling

```yaml
  podDisruptionBudget: {}
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
	
readinessProbe:
	initialDelaySeconds: 10
	periodSeconds: 10
	timeoutSeconds: 5
	successThreshold: 1
	failureThreshold: 3
```