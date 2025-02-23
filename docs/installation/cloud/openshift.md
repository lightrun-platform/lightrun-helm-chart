## Prerequisites

Before installing Lightrun on OpenShift, ensure the following:

- **Installed OpenShift Cluster**: Follow the [Installation Official Docs](https://docs.openshift.com/container-platform/latest/installing/overview/index.html).
    
- **Compatibility Matrix**: Check the Lightrun compatibility matrix for supported OpenShift versions: [Compatibility Matrix](docs/installation/compatibility_matrix).
    

## Installation Process

### 1. Enable OpenShift in `values.yaml`

Modify the `values.yaml` file to enable OpenShift support:

```
general:
  openshift: true
```

### 2. (Optional) Enable Embedded OpenShift Hostname

To use the default OpenShift domain for Lightrun (e.g., `https://lightrun.apps.test.o5mj.p1.openshiftapps.com/`), set the following:

```
general:
  openshift_embeded_hostname: true
```

In this case, ensure:

- The appropriate `lightrun_endpoint` is configured.
    
- The default OpenShift certificate is provided in the `certificate` section.
    
- The default certificate can be retrieved using:
    
    ```
    kubectl get secrets -n openshift-config-managed router-certs -o yaml
    ```
    
    **Requires admin permissions.**
    
- More details: [Ingress Certificates](https://docs.openshift.com/container-platform/latest/security/certificate_types_descriptions/ingress-certificates.html).
    

### 3. ### Configure StorageClass for Local RabbitMQ or MySQL (If Used)

By default, it is recommended to use **external** RabbitMQ and MySQL instances instead of local deployments. However, if you choose to run them locally, you need to configure the correct `storageClassName`.

- **RabbitMQ** is an optional component and is only required if telemetry data needs to be sent to Lightrun.
    
- Ensure that the appropriate storage class is set for local deployments. You can check the default storage class using the following command:
```
kubectl get storageclass
```
#### MySQL Configuration (If used locally):

```
general:
  statefulset:
    storageClassName: gp2
```

#### RabbitMQ Configuration (If used locally):

```
general:
  mq:
    storageClassName: gp2
```

### 4. Configure OpenShift Ingress (HAProxy)

If using OpenShift's default HAProxy ingress controller, adjust the router configuration accordingly. Follow the guide: [Install Lightrun Router on openshift with HAProxy](openshift_haproxy.md).