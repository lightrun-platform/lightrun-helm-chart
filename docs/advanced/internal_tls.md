### Overview

By default, internal communication between pods within the cluster is not encrypted, as SSL operations can be computationally expensive. Typically, SSL termination occurs at the client-facing load balancer. However, certain security policies may require SSL encryption for all internal communications. While service mesh proxies often handle this requirement, there are cases where encryption must be enforced at the pod level.

> [!WARNING] Attention
> Enabling internal TLS increases resource consumption, as additional computational power is required for SSL operations.

### Enabling Internal TLS

To activate internal TLS, set the `enabled` flag to `true`:

```yaml
general:
	internal_tls:
	  enabled: true
```

### Providing TLS Certificates

There are two ways to supply certificates to pods:

```yaml
general:
	internal_tls:
		certificates:
		  source: "choose one of the two options below"
```

#### Option 1: `generate_self_signed_certificates` (Default)

This option generates self-signed certificates for all pods except backend and MySQL. The certificate's Common Name (CN) includes the service name, and the generated certificates are valid for 10 years. These certificates are stored in Kubernetes secrets of type `kubernetes.io/tls`.

The Helm chart applies the following hooks to these secrets:

```
"helm.sh/hook": "pre-install"
"helm.sh/hook-delete-policy": "before-hook-creation"
```

This prevents secrets from being recreated during `helm upgrade` operations.

> [!NOTE] Note for ArgoCD Users
> ArgoCD will replace these secrets during a "full sync" operation, but this does not disrupt existing deployments. Since pods are not redeployed upon certificate updates, they continue functioning as usual. If pods are restarted, they will retrieve the new certificates automatically.

#### Option 2: `existing_certificates`

If you prefer to use externally generated certificates, specify the Kubernetes secret names containing them. Each secret must include the `tls.crt` and `tls.key` keys.

If a certificate’s Subject Alternative Name (SAN) includes all necessary services, the same certificate can be reused across multiple pods.

```yaml
general:
	internal_tls:
		certificates:
			existing_certificates:
			  frontend: ""
			  keycloak: ""
			  redis: ""
			  rabbitmq: ""
			  data_streamer: ""
```

> [!NOTE] 
> The secrets must exist in the same namespace as the deployment.

### Certificate Verification

By default, pods verify remote SSL certificates. This behavior can be modified using the following flag:

```yaml
general:
	internal_tls:
		certificates:
		  verification: true
```

If you use a private Certificate Authority (CA), specify a Kubernetes secret containing the CA certificate used to sign all internal certificates. This secret must contain a `ca.crt` key:

```yaml
general:
	internal_tls:
		certificates:
		  existing_ca_secret_name: some-ca-secret
```

> [!NOTE] 
> The CA secret must be in the same namespace as the deployment.
