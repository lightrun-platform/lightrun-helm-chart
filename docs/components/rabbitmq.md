# RabbitMQ

RabbitMQ is used at Lightrun to decouple and buffer event-driven data such as telemetry and user actions between internal services.  
It ensures reliable delivery and backpressure control for high-throughput pipelines that process events to mixpanel and keycloak events.

This page configures **RabbitMQ** as the message queue. 
There are two modes:  
- Local RabbitMQ Deployment - The chart deploys a **local RabbitMQ instance** inside the cluster (`general.mq.local: true`) 
- External RabbitMQ Deployment: The chart connects to an **external RabbitMQ instance** (`general.mq.local: false`).

> [!NOTE]
> When using external RabbitMQ, ensure that the provided endpoints are reachable.

> [!Important]
> - Support RabbitMQ versions 3.12.x.
> - Minimum size requirements: 0.5 vCPU, 1Gi memory.

### **Basic Configuration**
| Property                                             | Description                                                                                               |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| **`general.mq.enabled: false`**                      | Enable (`true`) or disable (`false`) RabbitMQ.                                                            |
| **`general.mq.local: true`**                         | If `true`, a RabbitMQ **StatefulSet** will be deployed inside the cluster.                                |
| **`general.mq.mq_endpoint: "rabbitmq.example.com"`** | The **fully qualified domain name (FQDN)** of an external RabbitMQ instance. **Ignored** if `local: true` |
| **`general.mq.port: "5672"`**                        | The **RabbitMQ connection port** (default: `5672`).                                                       |

> [!NOTE]
>   - If `general.mq.local: false`, all other RabbitMQ properties (such as storage, policies or metrics) **will be ignored** because the external RabbitMQ is expected to be pre-configured.
>   - If `general.mq.local: true`, only 1 replica of rabbitmq will be deployed. in addition, we do not support more than 1 replica of rabbitmq with local. Such configuraitons will result in unexpected behavior.

### **External RabbitMQ Configuration (general.mq.local: false)**
To use an external Rabbitmq instance, set general.mq.local to true. In this mode, the chart will not deploy a local Rabbitmq pod but will connect to an existing rabbitmq.

```yaml
  mq:
    enabled: true
    local: false
    mq_endpoint: saas-rabbitmq # the k8s service name or the FQDN of the external RabbitMQ instance, like "rabbitmq.external.example.com"
    port: "5672"
```

> [!IMPORTANT]
> - When using external RabbitMQ, local deployment settings (image, resources, health probes, etc.) do not apply.
> - For instructions on integrating with RabbitMQ Cluster Kubernetes Operator , see [Integrating Lightrun with RabbitMQ Cluster Kubernetes Operator](../advanced/rabbitmq-cluster-kubernetes-operator-integration.md).
---

### **Local RabbitMQ Configuration (general.mq.local: true)**

- **`general.mq.queue_names: ["mixpanel-events","keycloak-events"]`** – The declared RabbitMQ queues names.
    - **Changing this values** creates new queues (and a corresponding Dead Letter Queues).
    - Old queues **will not be deleted automatically**.
    - New messages will be sent to the new queues.

#### **Policy Configuration**

The following policy applies to **all queues matching** the regex pattern specified:

```yaml
general:
  mq:
    policy:
      queue_regex_pattern: "^.*-events.*"
      message_ttl: 600000000
      max_length: 2000
      overflow: "reject-publish"
      max_length_bytes: 1000000
```

| Property                         | Description                                                                     |
| -------------------------------- | ------------------------------------------------------------------------------- |
| **`queue_regex_pattern`**        | Regex pattern to match queues for policy application.                           |
| **`message_ttl: 600000000`**     | Time-to-live (TTL) for messages in milliseconds (**~7 days**).                  |
| **`max_length: 2000`**           | Maximum number of messages allowed in the queue.                                |
| [**`overflow: "reject-publish"`**](https://www.rabbitmq.com/docs/maxlength#overflow-behaviour) | Behavior when `max_length` is reached (`reject-publish` prevents new messages). |
| **`max_length_bytes: 1000000`**  | Maximum total size of all messages (**500 bytes × 2000 messages**).             |

This configuration **prevents queue overload** and ensures messages are retained only as needed.


#### **Storage Configuration (Only if `general.mq.local: true`)**

```yaml
general:
  mq:
    persistentVolumeClaimRetentionPolicy:
      whenDeleted: "Retain"
      whenScaled: "Retain"
    storageClassName: "gp3"
    storage: "10Gi"
    pvc_name: ""
```

|Property|Description|
|---|---|
|**`storageClassName: "gp3"`**|The storage class for the PersistentVolumeClaim (PVC).|
|**`storage: "10Gi"`**|Amount of storage allocated for RabbitMQ.|
|**`pvc_name: ""`**|PVC name (default: `{{ .Release.Name }}-mq-data`).|
|**`persistentVolumeClaimRetentionPolicy`**|Controls PVC retention when the StatefulSet is deleted or scaled down.|

> [!WARNING]
> To **disable persistent storage**, set `storage: "0"` (all data will be lost on pod restart). This creates a deployment instead of statefulset.

#### **Metrics Configuration**

- **`general.mq.metrics: false`** – If `true`, enables the **RabbitMQ Prometheus plugin**.
- Metrics are exposed on port `15692` via the RabbitMQ service.

To collect these metrics using **Prometheus autodiscovery**, add the following annotations to rabbitmq deployment (only applicable when `general.mq.local: true`):

```yaml
deployments:
  rabbitmq:
    service:
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/path: '/metrics'
        prometheus.io/port: '15692'

```
#### **Pod Configuration**
This is the **default RabbitMQ pod configuration**.
Configuration is defined under **`deployments.rabbitmq`** in the **`values.yaml`** file.
```yaml
deployments:
  rabbitmq:
    loglevel: info
    useJsonLogFormat: false
    image:
      repository: lightruncom/rabbitmq
      tag: 3.12.14-alpine
      pullPolicy: IfNotPresent
    resources:
      cpu: 500m
      memory: 1Gi
    podLabels: {}
    podAnnotations: {}
    service:
      annotations: {}
      labels: {}
      ## prometheus autodiscovery annotations could be added to the service
    nodeSelector: {}
    podSecurityContext:
      # when using a PVC , you must set `fsGroup` so pod will have write permission to the mounted volume
      # fsGroup should be aligned with `runAsUser` of the container
      fsGroup: 1000000
    containerSecurityContext: {}
    initContainers:
      rabbitmq_config:
        resources:
          cpu: 100m
          memory: 128Mi
        image:
          repository: lightruncom/chart-helper
          tag: latest
          pullPolicy: ""
    # EmptyDir is used for rabbitmq data when mq.storage is set to 0
    emptyDir:
      sizeLimit: 5Gi
    affinity: {}
    lifecycle:
      postStart:
        exec:
          command:
            - "/bin/sh"
            - "-c"
            - |
              rabbitmqctl wait --pid 1 --timeout 60 && \
              rabbitmqctl list_users | grep -q $RABBITMQ_DEFAULT_USER || \
              (rabbitmqctl add_user $RABBITMQ_DEFAULT_USER $RABBITMQ_DEFAULT_PASS && \
              rabbitmqctl set_user_tags $RABBITMQ_DEFAULT_USER administrator && \
              rabbitmqctl set_permissions -p / $RABBITMQ_DEFAULT_USER ".*" ".*" ".*")
    # The postStart lifecycle hook ensures proper RabbitMQ user setup:
    # 1. Waits for RabbitMQ to be ready (up to 60 seconds)
    # 2. Checks if the default user exists
    # 3. If user doesn't exist:
    #    - Creates the default user with provided credentials
    #    - Sets user as administrator
    #    - Grants full permissions on all vhosts
    livenessProbe:
      initialDelaySeconds: 60
      periodSeconds: 45
      timeoutSeconds: 15
      successThreshold: 1
      failureThreshold: 3
    readinessProbe:
      initialDelaySeconds: 20
      periodSeconds: 45
      timeoutSeconds: 10
      successThreshold: 1
      failureThreshold: 3
```

#### **Example of Local Redis Configuration**

#### **Deploy a Local RabbitMQ Instance with 10Gi Storage**
```yaml
general:
  mq:
    enabled: true
    local: true
    storageClassName: "gp3"
    storage: "10Gi"
    metrics: true
```