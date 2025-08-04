# Integrating Lightrun with RabbitMQ Cluster Kubernetes Operator

This guide explains how to configure the Lightrun Helm chart to work with RabbitMQ Cluster Kubernetes Operator on Kubernetes clusters.

## Prerequisites

- Kubernetes cluster with RabbitMQ Cluster Kubernetes Operator version >= 2.2.0 (Chart version >= 3.4.1) installed
- PV provisioner support in the underlying infrastructure

## Configuration Steps

### 1. Create RabbitMQ Cluster
Create a RabbitMQ cluster using the RabbitMQ Cluster Kubernetes Operator. You can use the following example YAML to create a RabbitMQ cluster:

```yaml
apiVersion: rabbitmq.com/v1beta1
kind: RabbitmqCluster
metadata:
  labels:
    app.kubernetes.io/instance: saas
  name: rabbitmq-cluster
  namespace: lightrun
spec:
  delayStartSeconds: 30
  image: rabbitmq:3.12.12-alpine
  override:
    statefulSet:
      spec:
        template:
          spec:
            containers:
              - name: rabbitmq
                env:
                  - name: RABBITMQ_DEFAULT_USER
                    valueFrom:
                      secretKeyRef:
                        name: backend
                        key: SPRING_RABBITMQ_USERNAME
                  - name: RABBITMQ_DEFAULT_PASS
                    valueFrom:
                      secretKeyRef:
                        name: backend
                        key: SPRING_RABBITMQ_PASSWORD
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
                volumeMounts:
                  - mountPath: /etc/rabbitmq/definitions.json
                    subPath: definitions.json
                    name: definitions
            volumes:
              - name: definitions
                configMap:
                  name: definitions
              - name: rabbitmq-confd
                projected:
                  defaultMode: 420
                  sources:
                    - configMap:
                        items:
                          - key: operatorDefaults.conf
                            path: operatorDefaults.conf
                          - key: userDefinedConfiguration.conf
                            path: userDefinedConfiguration.conf
                        name: rabbitmq-cluster-server-conf
  persistence:
    storage: 10Gi
    storageClassName: resize-sc
  rabbitmq:
    additionalConfig: |
      cluster_partition_handling = pause_minority
      vm_memory_high_watermark.relative = 0.8
      disk_free_limit.relative = 2.0
      collect_statistics_interval = 10000
      management_agent.disable_metrics_collector = false
      log.console.formatter = json
      load_definitions = /etc/rabbitmq/definitions.json
      definitions.skip_if_unchanged = false
      definitions.import_backend = local_filesystem
      definitions.local.path = /etc/rabbitmq/definitions.json
  replicas: 3
  resources:
    limits:
      cpu: 500m
      memory: 1000Mi
    requests:
      cpu: 500m
      memory: 1000Mi
  secretBackend:
    externalSecret: {}
  service:
    annotations: {}
    type: ClusterIP
  terminationGracePeriodSeconds: 300
  tls: {}
  ```

A `definitions.json` file is used to declaratively configure RabbitMQ resources such as vhosts, policies, and queues. When imported, RabbitMQ applies these settings to enforce queue behavior, message TTLs, memory limits, and routing rules, ensuring consistent and automated broker configuration.
These are the list of resources that will be created by the `definitions.json` file:

### Policies
| Name                                                  | VHost | Pattern         | Apply To | Definition                                                           | Priority |
|-------------------------------------------------------|-------|-----------------|----------|----------------------------------------------------------------------|----------|
| bi-queue-limiter-policy                               | /     | ^.*-events.*    | queues   | max-length: 2000, overflow: reject-publish                          | 2        |
| total-memory-consumed-by-messages-in-queue-policy     | /     | ^.*-events.*    | queues   | max-length-bytes: 1000000                                           | 1        |
| maximum-time-message-stay-in-queue-policy             | /     | ^.*-events.*    | queues   | message-ttl: 600000000                                               | 0        |

### Queues
| Name                  | VHost | Durable | Auto Delete | Dead Letter Exchange | Dead Letter Routing Key     | Queue Type | Created By |
|-----------------------|-------|---------|--------------|----------------------|-----------------------------|------------|------------|
| mixpanel-events.dlq   | /     | true    | false        |                      |                             | quorum     | chart      |
| mixpanel-events       | /     | true    | false        | ""                   | mixpanel-events.dlq         | quorum     | chart      |
| keycloak-events       | /     | true    | false        | ""                   | keycloak-events.dlq         | quorum     | chart      |
| keycloak-events.dlq   | /     | true    | false        |                      |                             | quorum     | chart      |

Deploy the following configmap which is used to define the RabbitMQ resources via the definitions.json file:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: definitions
  namespace: lightrun
data:
  definitions.json: |
    {
      "vhosts":[
        {"name": "/"}
      ],
      "policies": [
        {
          "vhost": "/",
          "name": "bi-queue-limiter-policy",
          "pattern": "^.*-events.*",
          "apply-to": "queues",
          "definition": {
            "max-length": 2000,
            "overflow": "reject-publish"
          },
          "priority": 2
        },
        {
          "vhost": "/",
          "name": "total-memory-consumed-by-messages-in-queue-policy",
          "pattern": "^.*-events.*",
          "apply-to": "queues",
          "definition": {
            "max-length-bytes": 1000000
          },
          "priority": 1
        },
        {
          "vhost": "/",
          "name": "maximum-time-message-stay-in-queue-policy",
          "pattern": "^.*-events.*",
          "apply-to": "queues",
          "definition": {
            "message-ttl": 600000000
          },
          "priority": 0
        }
      ],
      "queues": [
        {
          "name": "mixpanel-events.dlq",
          "vhost": "/",
          "durable": true,
          "auto_delete": false,
          "arguments": {
            "x-queue-type": "quorum",
            "x-created-by": "chart"
          }
        },
         {
          "name": "mixpanel-events",
          "vhost": "/",
          "durable": true,
          "auto_delete": false,
          "arguments": {
            "x-dead-letter-exchange": "",
            "x-dead-letter-routing-key": "mixpanel-events.dlq",
            "x-queue-type": "quorum",
            "x-created-by": "chart"
          }
        },
        {
          "name": "keycloak-events",
          "vhost": "/",
          "durable": true,
          "auto_delete": false,
          "arguments": {
            "x-dead-letter-exchange": "",
            "x-dead-letter-routing-key": "keycloak-events.dlq",
            "x-queue-type": "quorum",
            "x-created-by": "chart"
          }
        },
        {
          "name": "keycloak-events.dlq",
          "vhost": "/",
          "durable": true,
          "auto_delete": false,
          "arguments": {
            "x-queue-type": "quorum",
            "x-created-by": "chart"
          }          
        }     
      ]
    }
```

### 2. Configure Lightrun Helm Chart Values

When deploying Lightrun using Helm, you need to set the following values to integrate with your created RabbitMQ cluster:

```yaml
  mq:
    enabled: true
    local: false
    mq_endpoint: <svc_name>
    port: "5672"
```

Replace the following placeholders:
- `<svc_name>`: The name of the service created for your Redis Enterprise Database

### 4. Verify Configuration

After applying the configuration, you can verify the connection by checking the Lightrun server logs. You should see successful RabbitMQ connection messages in the logs.
```
{"@timestamp":"2025-08-04T12:39:47.72694439Z","@version":"1","message":"Attempting to connect to: [dev-saas-rabbitmq:5672]","logger_name":"org.springframework.amqp.rabbit.connection.CachingConnectionFactory","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"lightrun-dev-saas-backend-78df5476b4-q4psc","LOG_FILE":"/tmp/athena-backend-server-lightrun-dev-saas-backend-78df5476b4-q4psc.log","dd.service":"backend","dd.env":"dev-saas","dd.version":"1.1"}
{"@timestamp":"2025-08-04T12:39:47.842515564Z","@version":"1","message":"Created new connection: rabbitConnectionFactory#53103e63:0/SimpleConnection@66d21ba9 [delegate=amqp://root@172.20.61.245:5672/, localPort=51734]","logger_name":"org.springframework.amqp.rabbit.connection.CachingConnectionFactory","thread_name":"main","level":"INFO","level_value":20000,"HOSTNAME":"lightrun-dev-saas-backend-78df5476b4-q4psc","LOG_FILE":"/tmp/athena-backend-server-lightrun-dev-saas-backend-78df5476b4-q4psc.log","dd.service":"backend","dd.env":"dev-saas","dd.version":"1.1"}
```

Verify that the resources were loaded via the rabbitmq logs:
```
{"time":"2025-08-04 12:34:56.895539+00:00","level":"info","msg":"Applying definitions from regular file at /etc/rabbitmq/definitions.json","domain":"rabbitmq","pid":"<0.560.0>"}                                                                                            │
{"time":"2025-08-04 12:34:56.896230+00:00","level":"info","msg":"Applying definitions from file at '/etc/rabbitmq/definitions.json'","domain":"rabbitmq","pid":"<0.560.0>"}                                                                                                  ││ {"time":"2025-08-04 12:34:56.896271+00:00","level":"info","msg":"Asked to import definitions. Acting user: rmq-internal","domain":"rabbitmq","pid":"<0.560.0>"}                                                                                                              ││ {"time":"2025-08-04 12:34:56.896381+00:00","level":"info","msg":"Importing concurrently 1 vhosts...","domain":"rabbitmq","pid":"<0.560.0>"}                                                                                                                                  │
{"time":"2025-08-04 12:34:56.903749+00:00","level":"info","msg":"Importing sequentially 3 policies...","domain":"rabbitmq","pid":"<0.560.0>"}                                                                                                                                ││ {"time":"2025-08-04 12:34:56.919342+00:00","level":"info","msg":"Importing concurrently 4 queues...","domain":"rabbitmq","pid":"<0.560.0>"}
```

## Notes

- Make sure the RabbitMQ Cluster service is accessible from the namespace where Lightrun is deployed
- The RabbitMQ Cluster endpoint should be in the format `svc_name.namespace.svc.cluster.local`
- Ensure network policies allow communication between Lightrun and RabbitMQ if any are in place
