This section configures **RabbitMQ** as the message queue. You can either:  
- Deploy a **local RabbitMQ instance** inside the cluster (`general.mq.local: true`) 
or  
* Connect to an **external RabbitMQ instance** (`general.mq.local: false`).


### **Basic Configuration**
| Property                                             | Description                                                                                               |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| **`general.mq.enabled: false`**                      | Enable (`true`) or disable (`false`) RabbitMQ.                                                            |
| **`general.mq.local: true`**                         | If `true`, a RabbitMQ **StatefulSet** will be deployed inside the cluster.                                |
| **`general.mq.mq_endpoint: "rabbitmq.example.com"`** | The **fully qualified domain name (FQDN)** of an external RabbitMQ instance. **Ignored** if `local: true` |
| **`general.mq.port: "5672"`**                        | The **RabbitMQ connection port** (default: `5672`).                                                       |

> [!NOTE] Notes
>   - If `general.mq.local: false`, all other RabbitMQ properties (such as storage and policies) **will be ignored** because the external RabbitMQ is expected to be pre-configured.
>   - If `general.mq.local: true`, only 1 replica of rabbitmq will be deployed.


### **Queue Configuration**

- **`general.mq.queue_name: "mixpanel-events"`** – The name of the RabbitMQ queue.
    - **Changing this value** creates a new queue (and a corresponding Dead Letter Queue).
    - Old queues **will not be deleted automatically**.
    - New messages will be sent to the new queue.

### **Policy Configuration**

The following policy applies to **all queues matching** the regex pattern specified:

```yaml
general:
  mq:
    policy:
      queue_regex_pattern: "^mixpanel-events.*"
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
| **`overflow: "reject-publish"`** | Behavior when `max_length` is reached (`reject-publish` prevents new messages). |
| **`max_length_bytes: 1000000`**  | Maximum total size of all messages (**500 bytes × 2000 messages**).             |

This configuration **prevents queue overload** and ensures messages are retained only as needed.

### **Storage Configuration (Only if `general.mq.local: true`)**

```yaml
general:
  mq:
    persistentVolumeClaimRetentionPolicy:
      whenDeleted: "Retain"
      whenScaled: "Retain"
    storageClassName: "gp2"
    storage: "10Gi"
    pvc_name: ""
```

|Property|Description|
|---|---|
|**`storageClassName: "gp2"`**|The storage class for the PersistentVolumeClaim (PVC).|
|**`storage: "10Gi"`**|Amount of storage allocated for RabbitMQ.|
|**`pvc_name: ""`**|PVC name (default: `{{ .Release.Name }}-mq-data`).|
|**`persistentVolumeClaimRetentionPolicy`**|Controls PVC retention when the StatefulSet is deleted or scaled down.|

> [!WARNING]
> To **disable persistent storage**, set `storage: "0"` (all data will be lost on pod restart). creates deployment instead of statefulset.

### **Metrics Configuration**

- **`general.mq.metrics: false`** – If `true`, enables the **RabbitMQ Prometheus plugin**.
- **Metrics are exposed on port `15692`** via the RabbitMQ service.

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

### **Example Configurations**

#### **1️) Deploy a Local RabbitMQ Instance with 10Gi Storage**
```yaml
general:
  mq:
    enabled: true
    local: true
    storageClassName: "gp2"
    storage: "10Gi"
    metrics: true
```
#### **2️) Connect to an External RabbitMQ Instance**

```yaml
general:
  mq:
    enabled: true
    local: false
    mq_endpoint: "rabbitmq.external.example.com"
    port: 5672
```