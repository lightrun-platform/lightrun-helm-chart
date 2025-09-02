# Lightrun Deployment Using Helm Quick Start Guide

This guide walks you through deploying Lightrun using Helm with a minimal configuration.

## Step 1: Pull the Helm Chart

Download the latest Lightrun Helm chart:
```bash
helm pull oci://registry-1.docker.io/lightruncom/lightrun-helm-chart --version <VERSION> --destination ./
```
Replace `<VERSION>` with the desired chart version. This will save the Helm chart as a `.tgz` file in the current directory. Refer to the [Versions Mapping](../installation/versions_mapping.md) to find the latest version.

## Step 2: Configure `values.yaml`

Create a `values-overwrite.yaml` file and modify the following settings for a minimal working configuration:
```yaml
general:
  name: "client-example-name"
  lightrun_endpoint: "lightrun.example.com"
  router:
    ingress:
      annotations:
        nginx.ingress.kubernetes.io/proxy-read-timeout: "90"  
        nginx.ingress.kubernetes.io/proxy-body-size: "25m"
certificate:
  tls:
    crt: "<BASE64_CRT>"
    key: "<BASE64_KEY>"
secrets:
  keycloak:
    password: "<KEYCLOAK_PASSWORD>"
  db:
    user: "<DB_USER>"
    password: "<DB_PASSWORD>"
  mq:
    user: "<MQ_USER>"
    password: "<MQ_PASSWORD>"
  redis:
    password: "<REDIS_PASSWORD>"
  license:
    content: "<LICENSE_CONTENT>"  # Provided by Lightrun
    signature: "<LICENSE_SIGNATURE>"  # Provided by Lightrun
  defaults:
    dockerhub_config:
      configContent: "<BASE64_DOCKERHUB_CONFIG>"  # Provided by Lightrun
```
### Key Configuration Details:

- **License** and **Dockerhub Credentials** are supplied by Lightrun.
- **MySQL** and **Redis** are deployed locally.
    
- **RabbitMQ** and **Datastreamer** services are disabled.
    
- **Secrets** are managed within the Helm chart.
    
- **Internal TLS** and **network policies** are disabled.
    
- **Docker images** are pulled from the Lightrun private repository on DockerHub (`lightruncom`).
    
- **Router** is exposed without SSL, relying on an ingress controller (such as Nginx) for SSL termination.
    

For a self-signed certificate, see the **"Generating a Self-Signed TLS Certificate"** section in the [Certificate Overview](certificate.md).

## Step 3: Install Lightrun

Once the configuration is ready, deploy Lightrun using the downloaded chart and your customized `values-overwrite.yaml` file:
```bash
helm upgrade --install lightrun ./lightrun-helm-chart-<VERSION>.tgz -f values-overwrite.yaml -n lightrun --create-namespace
```

## Troubleshooting

If you encounter issues during the installation or after deployment, use the following commands to help diagnose the problem:

### 1. Check Helm Deployment Status

Verify if the Lightrun release was installed successfully:
```bash
helm list -n lightrun
```
If Lightrun is not listed, it may not have been installed correctly. To reinstall it, run the installation command again.

### 2. View Helm Release Logs

If the Helm installation failed or you want more details on what happened, check the logs:
```bash
helm status lightrun -n lightrun
```

### 3. Check Kubernetes Pod Status

Ensure that all Lightrun-related pods are running:
```bash
kubectl get pods -n lightrun
```

If any pods are in a `CrashLoopBackOff` or `Error` state, check the pod logs for further insights:
```bash
kubectl logs <POD_NAME> -n lightrun
```
