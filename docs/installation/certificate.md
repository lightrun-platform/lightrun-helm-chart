## **Overview**

Lightrun requires a **mandatory TLS certificate** for securing:

1. **Backend Service** – This is crucial for **certificate pinning**, ensuring secure communication between the Lightrun server and IDE plugins or agents.
2. **Lightrun Router** – If **SSL termination** happens at the router level, this certificate is required.

> [!NOTE] Certificate requirements
> - **Encoding:** PEM
> - **Format:** PKCS#1 or PKCS#8

>[!IMPORTANT] Important
> 
>Unlike Internal TLS (`internal_tls`),  which is an optional feature that encrypts internal communication between Lightrun services. **This TLS certificate is mandatory** for backend security and router-level SSL termination.

## **Providing Certificate**

Lightrun allows certificate to be provided in two ways:

### **1️) Using an Existing Kubernetes Secret**

If you have an existing TLS secret, you can reference it:
```yaml
certificate:
  existing_cert: "my-tls-secret"
```

### **2️) Providing Certificate Contents Directly (Base64 Encoded)**

Alternatively, provide the TLS certificate and key as Base64-encoded values:
```yaml
certificate:
  tls:
    crt: "<base64-encoded-certificate>"
    key: "<base64-encoded-private-key>"
```
#### **Encoding TLS Certificates in Base64**

If you need to provide a certificate in `values.yaml`, it must be **Base64 encoded**.  
If your certificate includes a **certificate chain**, it must be in the correct order before encoding:
1. **Your certificate** (`my-cert.crt`)
2. **Intermediate certificate(s)** (`intermediate.crt`, if applicable)
3. **Root certificate** (`root.crt`)
If you have a **certificate chain**, merge them in the correct order before encoding:
```bash
cat my-cert.crt intermediate.crt root.crt > full-chain.crt
```
##### **Encoding the Certificate and Key in Base64**
##### **For Linux**
```
# Encode certificate (single certificate or full chain)
cat my-cert.crt | base64 -w 0 

# Encode private key file
cat my-cert.key | base64 -w 0
```
##### **For MacOS**
```
# Encode certificate (single certificate or full chain)
cat my-cert.crt | base64

# Encode private key file
cat my-cert.key | base64
```
**⚠️ Important Notes:**

- If using a **certificate chain**, encode the **full chain** (certificate → intermediate → root) instead of just the certificate.
- Encoding a misordered chain may result in TLS errors.
- The **Base64-encoded values must be placed in `values.yaml`** under `certificate.tls`.
## **Generating a Self-Signed TLS Certificate (Optional)**

If you don’t already have a TLS certificate, you can generate a self‑signed certificate for testing or development purposes. **Note:** Lightrun requires a TLS certificate for secure backend and router communication. While a self‑signed certificate works for non‑production use, for production environments, you should use a certificate issued by a trusted CA.

### **Using OpenSSL**

You can generate a self‑signed certificate using the following OpenSSL command:
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout my-tls.key -out my-tls.crt \
  -subj "/CN=yourdomain.com/O=Your Organization/C=US"

```
This command creates two files:

- **`my-tls.key`** – Your private key.
- **`my-tls.crt`** – Your self‑signed certificate.

## **Example Deployment Configuration**

### **Using an Existing Secret**
```yaml
certificate:
  existing_cert: "lightrun-certificate-secret"
```
### **Providing Certificate Directly**
```yaml
certificate:
  tls:
    crt: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t..."
    key: "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tL..."
```

