# Custom CA Certificate


The `customCa` block allows you to provide a custom Certificate Authority (CA) certificate to the application. This is optional — if no values are provided, no custom CA will be used.


```yaml
secrets:
  customCa:
    customCaCertificate: "" # Base64-encoded CA certificate content.
    existingCaSecret: "" # Name of an existing Kubernetes secret containing the CA certificate.
```

### Option 1: Provide the CA certificate directly

Use `customCaCertificate` to provide the base64-encoded content of your CA certificate.
A new Kubernetes Secret will be automatically created by the Helm chart.

`existingCaSecret` must not be set.

```yaml
secrets:
  customCa:
    customCaCertificate: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t..."
```

### Option 2: Use an existing Kubernetes Secret

Use `existingCaSecret` to reference an existing secret that contains your CA certificate.

`customCaCertificate` must not be set.


```yaml
secrets:
  customCa:
    existingCaSecret: "<my-custom-ca-secret>"
```

