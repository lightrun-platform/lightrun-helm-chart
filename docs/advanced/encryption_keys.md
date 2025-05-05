# Encryption Keys Management

This document describes how to manage encryption keys for the Lightrun platform.

## Overview

Lightrun uses encryption keys to secure sensitive data. You have two options for managing these keys:

1. **User-Provided Key (Recommended)**: You provide your own encryption key
2. **Auto-Generated Key**: The system generates a key automatically (not recommended for production)

## Important Notes

- For production environments, it is **strongly recommended** to provide your own encryption key
- When using GitOps tools (like ArgoCD) or other Helm templating tools, the auto-generated key feature is **not suitable** as it will generate a new key on every sync
- If you're using GitOps, you **must** provide the encryption key externally
- The encryption key must be exactly 32 bytes (256 bits) for AES-256 encryption
- Keys are mounted in the backend container at `/encryption-keys` with filenames in the format `encryption-key-N` where N is an incrementing number

## Configuration

### User-Provided Key

To provide your own encryption key, set the following in your `values.yaml`:

```yaml
secrets:
  keysEncryption:
    userEncryptionKey: "your-encryption-key-here"
```

The key should be a secure random string of exactly 32 bytes. You can generate one using:

```bash
openssl rand -base64 32
```

### Auto-Generated Key (Not Recommended for Production)

If you want the system to generate a key automatically, set:

```yaml
secrets:
  keysEncryption:
    userEncryptionKey: ""  # Leave empty to auto-generate
```

⚠️ **Warning**: This is not recommended for production environments or when using GitOps tools.

## Key Rotation

You can rotate encryption keys by enabling key rotation:

```yaml
secrets:
  keysEncryption:
    rotateKey: true
```

When key rotation is enabled:
- A new key will be generated (if not provided)
- The new key will be used for new data
- Old keys will be preserved to decrypt existing data

## GitOps Considerations

When using GitOps tools (like ArgoCD) or other Helm templating tools:

1. **Do not** use auto-generated keys
2. **Always** provide the encryption key externally
3. Store the key in a secure secret management system (e.g., Vault, AWS Secrets Manager)
4. Inject the key into your values during deployment

## Security Best Practices

1. Use a strong, randomly generated key of exactly 32 bytes
2. Store the key securely
3. Rotate keys periodically
4. Never commit encryption keys to version control
5. Use different keys for different environments
6. Document key rotation procedures
7. Have a backup of your keys

## Troubleshooting

### Common Issues

1. **Key not found**: Ensure the key is properly set in your values
2. **Decryption failures**: Verify you're using the correct key
3. **GitOps sync issues**: Check if you're using auto-generated keys with GitOps 