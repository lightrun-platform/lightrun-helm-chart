# Crons Service

The crons component is responsible for handling background processing tasks such as scheduled jobs, batch operations, and other background activities. This service runs the same application as the backend but with different configuration to focus on background tasks.

Configuration is defined under **`deployments.crons`** in the **`values.yaml`**

## Service Overview

The crons service provides:
- **Background Task Processing**: Dedicated processing of scheduled jobs and background operations
- **Performance Isolation**: Separates background processing from user-facing backend operations
- **Reliability**: Independent failure domain from the main backend service

## Enabling/Disabling the Service

The crons service is controlled by the global enable flag:

```yaml
general:
  crons:
    enabled: false  # Set to true to deploy the crons service
```

When enabled, the crons service will be deployed alongside the backend service with no external network exposure.

### Configuration Options

#### Image Configuration

```yaml
  image:
    repository: "lightruncom/server"
    tag: ""
    pullPolicy: IfNotPresent
```

#### Resource Allocation

```yaml
  resources:
    cpu: 3000m    # CPU limit (optimized for background processing)
    memory: 6Gi   # Memory limit (optimized for background processing)
```

#### Pod Labels & Annotations

```yaml
  podLabels: {}
  podAnnotations: {}
```

#### Application Metrics (Datadog Integration)

```yaml
  appMetrics:
    exposeToDatadog: false
    includeMetrics: []
    # Example:
    # includeMetrics: ["connected_agents_per_runtime","connected_agents_total","actions_count_active_total","companies_count_total"]
```

#### Extra Environment Variables

```yaml
  extraEnvs: []
```

> **Note:** Environment variables defined in `extraEnvs` will be merged with backend `extraEnvs`. Crons-specific variables take precedence over backend variables with the same name.

#### Security Contexts

```yaml
  podSecurityContext: {}
  containerSecurityContext: {}
```

#### Volumes 

```yaml
  extraVolumes: []
  extraVolumeMounts: []
  dumpsEmptyDirSizeLimit: 5Gi  # Size limit for dumps volume
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

#### AsyncProfiler Configuration

```yaml
  asyncProfiler:
    enabled: false  # Run async-profiler on every crons pod
    downloadUrl: "https://github.com/async-profiler/async-profiler/releases/download/v3.0/async-profiler-3.0-linux-x64.tar.gz"
    arguments: "start,event=ctimer,loop=10m,chunksize=1m,file=/async-profiler-tmp/profile-%t.jfr,log=/tmp/asyncprofiler.log"
    persistence:
      enabled: false
      existingClaim: ""
```

## Deployment Characteristics

### Replica Configuration
- **Fixed Replicas**: Always runs exactly 1 replica (no HPA support)
- **Deployment Strategy**: Uses `Recreate` strategy to ensure clean pod replacement
- **Purpose**: Single instance prevents duplicate execution of scheduled tasks

### Network Isolation
- **No Service Object**: The crons service does not expose any Kubernetes Service
- **Internal Processing Only**: Communicates only with shared backend services (DB, Redis, etc.)

## Architecture Integration

The crons service shares infrastructure components with the backend service through shared Helm templates:

- **Environment Variables**: Shares database, Redis, Keycloak, and other service connections
- **Volumes**: Shares encryption keys, certificates, and configuration volumes
- **Init Containers**: Uses the same initialization logic (wait-for-keycloak, p12-creator, etc.)
- **Security**: Identical security contexts and RBAC configurations

This shared architecture ensures consistency and reduces maintenance overhead while providing service isolation.

## Monitoring and Observability

The crons service exposes the same monitoring endpoints as the backend:
- **Health Endpoints**: `/management/health/readiness`, `/version`
- **Metrics**: Available at `/management/prometheus` (when enabled)
- **Container Port**: 8080 (internal monitoring only)