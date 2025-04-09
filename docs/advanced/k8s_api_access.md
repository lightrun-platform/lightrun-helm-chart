# System Diagnostics: Kubernetes API Integration

This document describes how to enable and configure the System Diagnostics feature to access the Kubernetes API from the backend pod. This integration allows the System Diagnostics feature to collect detailed information about the Lightrun deployment's Kubernetes environment.

## Overview

The System Diagnostics feature can be configured to access the Kubernetes API from the backend pod to enhance its diagnostic capabilities. This integration provides valuable insights into the Kubernetes environment where Lightrun is deployed, enabling more comprehensive system monitoring and troubleshooting.

## Prerequisites

Before enabling this feature, ensure that:

1. The `serviceAccount.create` setting is set to `true` in your values.yaml
2. Your Kubernetes cluster allows service account token mounting
3. You have the necessary permissions to create Roles and RoleBindings in the namespace where Lightrun is deployed

## Configuration

To enable Kubernetes API access, set the following in your values.yaml:

```yaml
general:
  system_diagnostics_k8s_api:
    enabled: true
```

## How It Works

When enabled, this feature:

1. Creates a Role and RoleBinding that grant the backend pod permission to:
   - List and get resources in the Lightrun namespace
   - Access basic cluster information

2. Mounts the service account token to the backend pod, allowing it to authenticate with the Kubernetes API

3. Enables the backend to collect system diagnostics data about:
   - Pod status and resource usage
   - Node information
   - Cluster events
   - Resource limits and requests

## Security Considerations

⚠️ **Important Security Notes:**

- This feature requires mounting a service account token inside the pod, which may not be allowed in all environments
- The service account token provides access to Kubernetes API resources within the namespace
- Consider the security implications before enabling this feature in production environments
- Review your cluster's security policies regarding service account token mounting

## Troubleshooting

If the feature is not working as expected:

1. Verify that `serviceAccount.create` is set to `true`
2. Check that the service account token is properly mounted in the backend pod
3. Ensure the Role and RoleBinding were created successfully
4. Review the backend pod logs for any authentication or authorization errors

## Disabling the Feature

To disable Kubernetes API access:

```yaml
general:
  system_diagnostics_k8s_api:
    enabled: false
```

Note: Disabling this feature only affects the Kubernetes API data collection. Other system diagnostics features will continue to work as normal. 