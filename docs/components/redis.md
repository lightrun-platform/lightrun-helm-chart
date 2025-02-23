### Overview

Redis is used as a caching layer and data store within Lightrun. It can be deployed as a [**Local Redis**](#Local%20Redis) with the chart or used as an [**External Redis**](#External%20Redis). This is controlled by the settings under `deploymets.redis` in `values.yaml`.

There are two modes:

- **Local Redis Deployment** (`deployments.redis.external.enabled: false`): The chart deploys a local Redis instance.
- **External Redis Deployment** (`deployments.redis.external.enabled: true`): The chart connects to an externally managed Redis instance. In this mode, the configuration depends on the `deployments.redis.architecture` setting:
    - For **single** architecture, specify the `endpoint`.
    - For **replicated** architecture, provide the `replicatedConfig.nodeAddresses` (this list is mandatory).

> [!NOTE]
>  When using external Redis, ensure that the provided endpoints are reachable. Also, if using replicated architecture, the list of node addresses must be correctly provided.


### Configuration Options

#### General Settings
```yaml
deployments:
	redis:
	  architecture: single  # (single|replicated) Determines how the backend treats Redis.
	  encryption:
	    enabled: false      # Enable SSL encryption for Redis transport.
	  port: "6379"          # Redis port. Adjust if your external provider requires a different port (e.g., Azure Cache for Redis uses 6380).
	  auth:
	    enabled: false      # Enable Redis authentication. Requires secrets.redis.password to be set.

```
---
#### Local Redis

When using a local Redis deployment (i.e., `deployments.redis.external.enabled: false`), the chart deploys a local Redis instance with the following characteristics:

- **Single Replica Only**: The local deployment always uses one replica.
- All deployment settings (image, resources, persistence, and health probes) apply.

```yaml
deployments:
	redis:
	  external:
	    enabled: false  # Local Redis will be deployed as part of the chart.
	  image:
	    repository: lightruncom/redis
	    tag: alpine-7.2.5-r1
	    pullPolicy: IfNotPresent
	  resources:
	    cpu: 2000m
	    memory: 6500Mi
	  podLabels: {}
	  podAnnotations: {}
	  annotations: {}
	  podSecurityContext: {}
	  containerSecurityContext: {}
	  service:
	    annotations: {}
	    labels: {}
	  emptyDir:
	    sizeLimit: 5Gi  # Used for local Redis data persistence.
	  affinity: {}
	  livenessProbe:
	    initialDelaySeconds: 50
	    periodSeconds: 30
	    timeoutSeconds: 5
	    successThreshold: 1
	    failureThreshold: 3
	  readinessProbe:
	    initialDelaySeconds: 30
	    periodSeconds: 10
	    timeoutSeconds: 5
	    successThreshold: 1
	    failureThreshold: 3
```
- The chart uses an **EmptyDir** for data persistence.
- Local deployment is suitable for development or smaller installations. For production, verify that your resources and persistence settings meet your requirements.
---
#### External Redis

To use an external Redis instance, set `redis.external.enabled` to `true`. In this mode, the chart will not deploy a local Redis pod but will connect to an existing redis.

- **Single Architecture (default):**
```yaml
deployments:
	redis:
	  external:
	    enabled: true
	    endpoint: "redis.example.com"  # External Redis endpoint (FQDN)
```
* ***Replicated Architecture (commonly used with AWS ElastiCache):**:
```yaml
deployments:
	redis:
	  architecture: replicated  # Use replicated mode for Redis.
	  external:
	    enabled: true
	    replicatedConfig:
	      nodeAddresses: ["redis-1.example.com", "redis-2.example.com"]  # List of FQDNs for reachable Redis nodes (mandatory for replicated mode)
```

> [!IMPORTANT] 
> - When using external Redis, local deployment settings (image, resources, health probes, etc.) do not apply.
> - In replicated mode, providing the list of node addresses is **mandatory** for proper connectivity.



---