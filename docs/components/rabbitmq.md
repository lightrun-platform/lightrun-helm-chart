# RabbitMQ

RabbitMQ is used at Lightrun to decouple and buffer event-driven data such as telemetry and user actions between internal services. It ensures reliable delivery and backpressure control for high-throughput pipelines that process events for Mixpanel and Keycloak integrations.

This page configures **RabbitMQ** as the message queue. 
There are two modes:  
- Local RabbitMQ Deployment - The chart deploys a **local RabbitMQ instance** inside the cluster (`general.mq.local: true`) 
- External RabbitMQ Deployment: The chart connects to an **external RabbitMQ instance** (`general.mq.local: false`).

> [!NOTE]
> When using external RabbitMQ, ensure that the provided endpoints are reachable.

> [!Important]
> - Supports RabbitMQ versions 3.12.x.
> - Minimum size requirements: 0.5 vCPU, 1Gi memory.

## RabbitMQ Enabled by Default in 3.30.0 Chart Version

Starting with the 3.30.0 chart version, RabbitMQ is enabled by default with ephemeral storage (storage: "0"), eliminating the need for Persistent Volumes (PVs). This change ensures a smoother upgrade experience while maintaining compatibility with existing configurations.

### Upgrade Implications for RabbitMQ Configuration

Review the following scenarios to determine the necessary actions for your upgrade.

- RabbitMQ Was Unused (Default Settings)
  - Condition: You were not using RabbitMQ and relied on default settings.
  - Outcome: RabbitMQ will now be automatically enabled with ephemeral storage.
  - Action: You must set non-blank RabbitMQ credentials. The method depends on your secret configuration:
    - If using deployed secrets (`general.deploy_secrets.enabled: true`): Set `secrets.mq.user` and `secrets.mq.password` in your `values.yaml`.
    - If using an existing secret (`general.deploy_secrets.enabled: false`): Set the `SPRING_RABBITMQ_USERNAME` and `SPRING_RABBITMQ_PASSWORD` fields in the existing secret referenced by `general.deploy_secrets.existing_secrets.backend`.

- RabbitMQ Was Explicitly Disabled
  - Condition: Your `values.yaml` contained `general.mq.enabled: false`.
  - Outcome: RabbitMQ remains disabled.
  - Action: None required.

- RabbitMQ Was Used with Default Persistent Storage
  - Condition: You were using the local RabbitMQ with the default `storage: "10Gi"` setting.
  - Outcome: The default storage will change to ephemeral, which does not persist data across pod restarts.
  - Action: To retain persistent storage, you must explicitly set `general.mq.storage: "10Gi"` in your `values.yaml`.

- Using an External RabbitMQ Service
  - Condition: Your configuration points to an external RabbitMQ instance.
  - Outcome: No change to your configuration.
  - Action: None required.


> [!NOTE]
> **For air-gapped or restricted environments**: If your environment has no access to DockerHub, you must provide the RabbitMQ container image (like `lightruncom/rabbitmq:4.0.9-alpine.lr-0`) through your internal container registry. Override the image source in your `values.yaml` as shown below:
> ```yaml
> general:
>   mq:
>     image:
>       repository: your-internal-registry.example.com/lightruncom/rabbitmq
>       tag: 4.0.9-alpine.lr-0
> ```



### **Basic Configuration**
| Property                                             | Description                                                                                               |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| **`general.mq.enabled: true`**                      | Enable (`true`) or disable (`false`) RabbitMQ.                                                            |
| **`general.mq.local: true`**                         | If `true`, a RabbitMQ **StatefulSet** will be deployed inside the cluster.                                |
| **`general.mq.mq_endpoint: "rabbitmq.example.com"`** | The **fully qualified domain name (FQDN)** of an external RabbitMQ instance. **Ignored** if `local: true` |
| **`general.mq.port: "5672"`**                        | The **RabbitMQ connection port** (default: `5672`).                                                       |

> [!NOTE]
>   - If `general.mq.local: false`, all other RabbitMQ properties (such as storage, policies or metrics) **will be ignored** because the external RabbitMQ is expected to be pre-configured.
>   - If `general.mq.local: true`, only 1 replica of rabbitmq will be deployed. in addition, we do not support more than 1 replica of rabbitmq with local. Such configurations will result in unexpected behavior.

### **External RabbitMQ Configuration (general.mq.local: false)**
To use an external RabbitMQ instance, set general.mq.local to false. In this mode, the chart will not deploy a local RabbitMQ pod but will connect to an existing RabbitMQ.

```yaml
  mq:
    enabled: true
    local: false
    mq_endpoint: saas-rabbitmq # Kubernetes service name or FQDN (e.g., "rabbitmq.external.example.com")
    port: "5672"
```

> [!IMPORTANT]
> - When using external RabbitMQ, local deployment settings (image, resources, health probes, etc.) do not apply.
> - For instructions on integrating with RabbitMQ Cluster Kubernetes Operator , see [Integrating Lightrun with RabbitMQ Cluster Kubernetes Operator](../advanced/rabbitmq-cluster-kubernetes-operator-integration.md).
---

### **Local RabbitMQ Configuration (general.mq.local: true)**

- **`general.mq.queue_names: ["mixpanel-events","keycloak-events"]`** – The declared RabbitMQ queues names.
    - **Changing these values** creates new queues (and a corresponding Dead Letter Queues).
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
| **`max_length_bytes: 1000000`**  | Maximum total size of all messages (**~1MB total**).             |

This configuration **prevents queue overload** and ensures messages are retained only as needed.

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

#### **Example of Local RabbitMQ Configuration**


## PVC Removal in Chart Version 3.32.1

Starting with chart version 3.32.1, Persistent Volume Claim (PVC) support has been removed for RabbitMQ. RabbitMQ now exclusively uses ephemeral storage (`emptyDir`) for all data persistence.

### **What Changed**

- **Removed PVC Support**: RabbitMQ now exclusively uses ephemeral storage (`emptyDir`) for data persistence. The `general.mq.storage` configuration value no longer creates PVCs.
- **Deprecated Configuration Options**: The following configuration properties are no longer supported and should be removed from your `values.yaml`:
  - `general.mq.persistentVolumeClaimRetentionPolicy`
  - `general.mq.storageClassName`
  - `general.mq.storage` (no longer creates PVCs)
  - `general.mq.pvc_name`

### **Impact**

- **Data Persistence**: RabbitMQ data is stored in ephemeral storage only. **All data will be lost** when the pod is restarted or deleted.
- **Storage Configuration**: The `general.mq.storage` setting in `values.yaml` is now ignored. RabbitMQ uses the `emptyDir` size limit defined in `deployments.rabbitmq.emptyDir.sizeLimit` (default: `5Gi`).

### **Upgrade Considerations**

> [!WARNING]
> **Direct Helm Upgrade Will Fail**: Attempting to upgrade directly from a version using PVCs to version 3.32.1 will result in an error.

If you attempt a direct upgrade, you will encounter an error similar to:

```
Error: UPGRADE FAILED: cannot patch "lightrun-mq" with kind StatefulSet: 
StatefulSet.apps "lightrun-mq" is invalid: spec: Forbidden: updates to statefulset spec 
for fields other than 'replicas', 'ordinals', 'template', 'updateStrategy', 
'persistentVolumeClaimRetentionPolicy' and 'minReadySeconds' are forbidden
```

### **Migration Process**

If you are upgrading from a previous version that used PVCs, follow these steps to migrate to ephemeral storage:

**Step 1: Scale Down and Remove Existing Resources**

Scale down the StatefulSet, wait for pods to terminate, then delete the StatefulSet and associated PVC:

```bash
# Scale down the StatefulSet
kubectl scale statefulset <STATEFULSET_NAME> --replicas=0 -n <NAMESPACE>

# Verify pods are fully terminated
kubectl get pods -n <NAMESPACE>

# Delete the StatefulSet
kubectl delete statefulset <STATEFULSET_NAME> -n <NAMESPACE>

# Delete the associated PVC (optional, but recommended to free up storage)
kubectl delete pvc <PVC_NAME> -n <NAMESPACE>
```

**Step 2: Update Configuration**

Remove the following deprecated values from your `values.yaml`:

- `general.mq.persistentVolumeClaimRetentionPolicy`
- `general.mq.storageClassName`
- `general.mq.storage`
- `general.mq.pvc_name`

**Step 3: Upgrade Helm Release**

Upgrade your Helm release and verify the new deployment:

```bash
# Upgrade the Helm release
helm upgrade --install <RELEASE> . -n <NAMESPACE>

# Verify the pod is using emptyDir (not PVC)
kubectl describe pod <LIGHTRUN-MQ-POD> -n <NAMESPACE>
# Check the "Volumes" section to confirm no PVC is mounted
```
