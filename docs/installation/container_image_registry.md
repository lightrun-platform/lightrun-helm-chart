This document explains how to configure the container image registry. By default, the chart pulls images from a private DockerHub repository, but it also supports configuring a custom private registry.

## Default Image Repository

In the default `values.yaml`, the container images repository are defined as follows:
```yaml
deployments:
  frontend:
    image:
      repository: lightruncom/webapp
  backend:
    image:
      repository: lightruncom/server
    initContainers:
      wait_for_keycloak:
        image:
          repository: lightruncom/chart-helper
      p12_creator:
        image:
          repository: lightruncom/chart-helper
      wait_for_rabbitmq:
        image:
          repository: lightruncom/chart-helper
  keycloak:
    image:
      repository: lightruncom/keycloak
    initContainers:
      cluster_cert:
        image:
          repository: lightruncom/chart-helper
  redis:
    image:
      repository: lightruncom/redis
  rabbitmq:
    image:
      repository: lightruncom/rabbitmq
    initContainers:
      rabbitmq_config:
        repository: lightruncom/chart-helper
  data_streamer:
    image:
      repository: lightruncom/data-streamer
  router:
    image:
      repository: lightruncom/router
```
By default, `lightruncom` refers to a private repository on DockerHub.  To change the registry, update the `repository` values for **all images**:

```yaml
deployments:
  frontend:
    image:
      repository: myregistry.com/lightrun/webapp
  backend:
    image:
      repository: myregistry.com/lightrun/server
...      
```

## Configuring ImagePullSecrets for registry

The configuration is defined under `secrets.defaults.dockerhub_config`:
```yaml
secrets:
  defaults:
    dockerhub_config:
      existingSecret: ""
      configContent: ""
```

### Available Configuration Modes:

1. [Creating a New Secret for Private Registry(`configContent`)](#1-creating-a-new-secret-for-private-registryconfigcontent)) _(Default for Lightrun private registry)_
2. [Using an Existing ImagePullSecret(`existingSecret`)](#2-using-an-existing-imagepullsecretexistingsecret))
3. [Disabling ImagePullSecrets](#3-disabling-imagepullsecrets) _(Commonly used to allow anonymous calls)_

---
#### 1. Creating a New Secret for Private Registry(`configContent`)
In this mode, the chart will create the `imagePullSecrets`  secret based on the `configContent` provided during the installation.
```yaml
secrets:
  defaults:
    dockerhub_config:
      configContent: "BASE64_ENCODED_AUTH_CONFIG"
```
> [!NOTE]
> By default, the chart is configured to use `lightruncom` as a private registry, and the value for `configContent` is provided by the Lightrun persona.

However, if you are **not** using the default Lightrun private registry and instead need to use your own private registry that requires authentication, you will need to manually follow these steps to create the image pull secret as part of the chart:

To construct the `auth` field, first create an authentication string:
```
echo -n 'username:password' | base64
```
Then, use the result to build the JSON structure:
```json
{
  "auths": {
    "https://your-private-registry.com": {
      "auth": "BASE64_ENCODED_STRING"
    }
  }
}
```
Encode this JSON file into base64 before setting it in `configContent`:
```
cat auth.json | base64 -w 0
```
For more details on creating and managing Kubernetes image pull secrets, refer to the [official Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).

#### 2. Using an Existing ImagePullSecret(`existingSecret`)

If you have an existing Kubernetes secret for registry authentication, set the `existingSecret` field:
```yaml
secrets:
  defaults:
    dockerhub_config:
      existingSecret: my-container-registry-secret
```

#### 3. Disabling ImagePullSecrets

In this mode the registry that does not require authentication, disable `imagePullSecrets` by setting `dockerhub_config` to `null`:
```yaml
secrets:
  defaults:
    dockerhub_config: null
```

