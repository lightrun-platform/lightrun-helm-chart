# Managing the TLS Certificate (Mandatory)

Lightrun requires a **mandatory TLS certificate** for securing:

- **Backend Service**: This is crucial for **certificate pinning**, ensuring secure communication between the Lightrun server and IDE plugins or agents.
- **Lightrun Router**: If **SSL termination** happens at the router level, this certificate is required.

> [!NOTE] 
> Certificate requirements:
> - **Encoding:** PEM
> - **Format:** PKCS#1 or PKCS#8

> [!IMPORTANT]
> Unlike Internal TLS (`internal_tls`),  which is an optional feature that encrypts internal communication between Lightrun services, **This TLS certificate is mandatory** for backend security and router-level SSL termination.

## **Providing Certificate**

Lightrun allows the certificate to be provided in two ways:

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

- When using a **certificate chain**, encode the **full chain** (certificate → intermediate → root) instead of just the certificate.
- Encoding a misordered chain may result in TLS errors.
- The **Base64-encoded values must be placed in `values.yaml`** under `certificate.tls`.

## **Optional: multiple certificate pinning hashes (`security_pinned_hashes`)**

The backend exposes the mandatory TLS certificate to IDE plugins and agents and uses **certificate pinning** so clients only trust the expected public key.

By default, pinning follows the certificate currently mounted for the backend (a single expected hash). Set `certificate.security_pinned_hashes` when you need the server to **accept more than one SHA-256 SPKI pin hash at the same time**.

### **Why use more than one hash?**

- **Renewal with the same private key** (re-issue the same CSR): the public key—and therefore the pinning hash—usually **stays the same**, so you often do not need multiple hashes.
- **Rotation that replaces the private key** (new key pair): the leaf certificate changes and the SPKI hash **changes**. If clients (plugins/agents) still pin the old hash until they are upgraded, you need a **transition window** where **both** the old and new hashes are trusted. Listing both hashes in `security_pinned_hashes` allows that overlap.

At deploy time, the chart sets the backend environment variable `LIGHTRUN_SECURITY_PINNED_HASHES` to the **comma-separated** list of hashes from `values.yaml`.

Example:

```yaml
certificate:
  security_pinned_hashes:
    - "E8F47F3C8B2A1D9E4F6A0B1C2D3E4F5A6B7C8D9E0F1A2B3C4D5E6F708192A0B"
    - "A1B2C3D4E5F60718293A4B5C6D7E8F90123456789ABCDEF0123456789ABCDEF0"
```

Use **no spaces** inside each hash string. Order does not matter; include every hash that must be accepted during the overlap period.

### **How to compute the pinning hash**

The value must be the **SHA-256 digest of the DER-encoded Subject Public Key Info (SPKI)** of the certificate’s public key, expressed as **hexadecimal** (64 characters), matching what the Lightrun backend expects for `LIGHTRUN_SECURITY_PINNED_HASHES`.

From a PEM certificate file (for example the same `tls.crt` you deploy in the Kubernetes TLS secret):

```bash
# SHA-256 of SPKI, hexadecimal (lowercase); take the 64 hex characters only
openssl x509 -in tls.crt -noout -pubkey \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -hex \
  | awk '{ print $2 }'
```

If your tooling reports the digest with uppercase hex, normalize to the format required by your Lightrun version (often case-insensitive; keep one consistent style in `values.yaml`).

You can compute a hash for **each** certificate in a rotation (old and new leaf certs) and list both under `security_pinned_hashes` until all clients have moved to the new pin.

## **Generating a Self-Signed TLS Certificate (Optional)**

If you don’t already have a TLS certificate, you can generate a self‑signed certificate for testing or development purposes. 

> [!NOTE]
Lightrun requires a TLS certificate for secured backend and router communication. While a self‑signed certificate works for non‑production use, for production environments, you should use a certificate issued by a trusted CA.

### **Using OpenSSL**

You can generate a self‑signed certificate using the following OpenSSL command:
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout my-tls.key -out my-tls.crt \
  -subj "/CN=yourdomain.com/O=Your Organization/C=US"

```
This command creates two files:

- **`my-tls.key`**:Your private key.
- **`my-tls.crt`**: Your self‑signed certificate.

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

