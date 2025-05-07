# Encryption Keys

This document describes how to manage encryption keys for the Lightrun backend service. These keys are used to encrypt sensitive data such as:
- API keys for integrations (Datadog, SIEM Integration using Splunk, etc.)
- OpenAI Keys
- Other sensitive configuration data

You can either:

- **Recommended**: Connect to an External Encryption Key (`general.deploy_secrets.enabled: false`)
- **Not recommended for production**: Deploy a Chart-managed Encryption Key (`general.deploy_secrets.enabled: true`)

## Recommended Approach: External Encryption-Key (`general.deploy_secrets.enabled: false`)

For production environments, it's strongly recommended to manage encryption keys externally rather than letting the chart create and manage them. This approach provides better security and control over the encryption keys.

### Creating an External Encryption Key

1. Generate a secure encryption key:
   ```bash
   openssl rand -base64 32
   ```

   > [!IMPORTANT]
   > The encryption key must be:
   > - Exactly 32 byte
   > - Unique for each environment
   > - Stored securely (e.g., in a password manager or secret management system)

2. Create a Kubernetes secret containing all required fields, including the encryption key. See [Secrets Documentation](../installation/secrets.md) for the complete list of required fields.

3. Configure the chart to use the external secret:
```yaml
general:
  deploy_secrets:
    enabled: false
    existing_secrets:
      backend: <secret-name>
```

### Key Rotation with External Secrets

When rotating encryption keys, ensure your secret contains both the old and new encryption keys in the following format:
- `encryption-key-0`: The original key
- `encryption-key-1`: The new key

> [!IMPORTANT]
> - If you have created your own encryption key, store it in a Kubernetes secret and reference it via `existing_secrets.backend`. Do not put the key directly in values.yaml
> - For GitOps environments, you MUST provide stable encryption keys externally
> - Keep a secure backup of your encryption keys
> - Follow your organization's key rotation policies

## Alternative Approach: Chart-managed Encryption-Key (`general.deploy_secrets.enabled: true`)

For testing, POC, or development environments, you can let the chart create and manage the encryption key either by providing your own key via `keysEncryption.userEncryptionKey` or letting the chart auto-generate one if this parameter is empty. This is not recommended for production use.

### Steps to Use Chart-managed Secret

```yaml
secrets:
  keysEncryption:
    userEncryptionKey: ""  # Leave empty to auto-generate
    rotateKey: false       # Set to true to enable key rotation
```

> [!WARNING]
> This approach is not recommended for production environments. Use external secrets instead.> 
### Key Rotation with Chart-managed secret

When `rotateKey` is set to `true`, the chart will:
1. Generate a new key
2. Store both old and new keys in the secret
3. The backend will use both keys for decryption but only the new key for encryption

### Limitations of Chart-managed Keys

- For GitOps users (ArgoCD, Flux), each GitOps sync generates a new random key, making it incompatible with existing encrypted data.
- While the chart provides basic key rotation, there is no backup capability and no automated rotation policies (rotation can be done proactivly in a manual way).


> [!WARNING]
> For GitOps or production environments, you MUST use external secrets management to maintain a stable encryption key.

