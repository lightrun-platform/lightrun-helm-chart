# Data Streamer
The **Data Streamer** is an optional component that enables integration with **SIEM (Security Information and Event Management)** systems by forwarding audit logs. Configuration is split into two sections:

- **`general.data_streamer`**: Controls global settings such as enabling the component and retry policies.
- **`deployments.data_streamer`**: Defines deployment-specific settings such as scaling, resource allocation, and health probes.
## Configuration Options

### **Global Settings (`general.data_streamer`)**
```yaml
general:
  data_streamer:
    enabled: false  # Enables or disables the Data Streamer deployment
    authorization_header_name: Authorization  # Header used for authentication
    do_not_retry_on:
      - 403  # HTTP status codes upon which retries will not be attempted
```

### **Deployment Settings (`deployments.data_streamer`)**
#### Logging Configuration
```yaml
loglevel: INFO  # Logging level
useJsonLogFormat: false  # Enables structured JSON logging

```
#### Horizontal Pod Autoscaling (HPA) And Replicas
```yaml
replicas: 2
```
#### Deployment Strategy
```yaml
rollout_strategy: "RollingUpdate"
```
#### Image Configuration
```yaml
  image:
    repository: lightruncom/data-streamer  # Docker image repository
    tag: "rpk-4.45.1-alpine"  # Image tag
    pullPolicy: IfNotPresent  # Image pull policy
```
#### Resource Allocation
```yaml
  resources:
    cpu: 100m  # CPU limit
    memory: 128Mi  # Memory limit
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
  path: /ping

readinessProbe:
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
  path: /ready
```
