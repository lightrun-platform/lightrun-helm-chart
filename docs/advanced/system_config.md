# System Configuration File

This document describes how to configure and use the System Configuration feature in the Lightrun platform. The system configuration file allows administrators to adjust settings that control the behavior of the Lightrun server.

## Overview

The System Configuration is a JSON file that contains various settings that modify the behavior of the Lightrun server. This configuration is provided via a ConfigMap and mounted into the backend container. The file is digitally signed to ensure authenticity and prevent unauthorized modifications.

## Configuration Options

To use the System Configuration feature, you need to provide:

1. **Content**: The base64-encoded JSON configuration content (provided by Lightrun)
2. **Signature**: A base64-encoded signature of the JSON content (provided by Lightrun)

### Values.yaml Configuration

Add the following configuration to your `values.yaml` file or override the values when installing/upgrading the Helm chart:

```yaml
general:
  system_config:
    # Content of the system config file, base64 encoded
    content: "ewogICJzb21lQ29uZmlndXJhdGlvbkZpZWxkIjogdHJ1ZSwKICAiYW5vdGhlckNvbmZpZ3VyYXRpb25GaWVsZCI6IDEyMwp9Cg=="
    # Signature of the system config file, base64 encoded (provided by Lightrun)
    signature: "c2lnbmF0dXJlLXZhbHVlLWZyb20tbGlnaHRydW4="
```

> [!IMPORTANT]
> - The content must be base64-encoded valid JSON
> - The signature must be base64-encoded and match the content exactly to be considered valid
> - Contact Lightrun support to obtain a valid signature and content

### How It Works

When the Lightrun backend starts:

1. The backend reads the system configuration file
2. It validates the file's signature against the provided signature value
3. If valid, the configuration is applied to modify the backend's behavior
4. If invalid, the backend will log an error and may use default settings instead

## Updating the Configuration

To update the system configuration:

1. Obtain a new configuration content and corresponding signature from Lightrun support
2. Update your `values.yaml` file or use `--set` parameters with the new values
3. Apply the changes using Helm:

```bash
helm upgrade lightrun lightrun/lightrun -f values.yaml
```

> [!NOTE]
> Updating the system configuration requires a restart of the Lightrun backend deployment with strategy recreate to take effect.

## Troubleshooting

If you experience issues with the system configuration:

1. Verify that the content is properly base64-encoded
2. Ensure the signature matches the provided content
3. Check the backend logs for any error messages related to system configuration:

```bash
kubectl logs -l <lightrun-backend> -n <namespace>
```

For assistance with system configuration issues, contact Lightrun support. 