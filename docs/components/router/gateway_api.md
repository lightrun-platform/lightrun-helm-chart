# Kubernetes Gateway API
This section configures the **Lightrun Router** with the **[Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)**, the successor to the Ingress API.

The chart renders an `HTTPRoute` that sends all traffic for `general.lightrun_endpoint` to the Lightrun Router Service. The route can attach to a Gateway that your cluster admin already runs, or to a `Gateway` that the chart creates. When the router serves HTTPS, the chart also renders a `BackendTLSPolicy` so that the Gateway connects to the router over TLS and validates its certificate.

Gateway API support is **disabled by default**. Existing installations don't change until you set `general.router.gateway_api.enabled: true`.

## Prerequisites
The cluster must already provide:
1. **Gateway API CRDs** (`gateway.networking.k8s.io`), v1.2 or later, from the standard channel.
2. **A Gateway API implementation** (controller) and its `GatewayClass`, for example Envoy Gateway, NGINX Gateway Fabric, Istio, Cilium, the GKE Gateway controller, or the AWS Load Balancer Controller.
3. **Only if the router serves HTTPS** (`general.router.tls.enabled` or `general.internal_tls.enabled`): the `BackendTLSPolicy` CRD, `v1` (Gateway API v1.4+) or `v1alpha3`. Some platforms don't provide it. See the [portability table](#portability).
4. A DNS record for `general.lightrun_endpoint` that points to the Gateway's external address.

The chart checks `.Capabilities.APIVersions` and fails with an explicit message when the required CRDs are missing. See [Rendering without cluster access](#rendering-without-cluster-access) for `helm template` and GitOps pipelines.

## Configuration reference
All keys are under `general.router.gateway_api`:

| Key | Default | Description |
|---|---|---|
| `enabled` | `false` | Render the Gateway API resources. This is independent of `general.router.ingress.enabled`, so both can run side by side during a migration. |
| `validate_crds` | `true` | Fail when the Gateway API CRDs are not found in the cluster. |
| `parentRefs` | `[]` | Gateway(s) the `HTTPRoute` attaches to. Required unless `gateway.create` is `true`. |
| `hostnames` | `[]` | Hostnames on the `HTTPRoute`. If empty, `[general.lightrun_endpoint]` is used. |
| `timeouts` | `{}` | `HTTPRoute` rule timeouts (`request`, `backendRequest`). See [Timeouts and body size](#timeouts-and-body-size). |
| `filters` | `[]` | `HTTPRoute` rule filters, for example `RequestHeaderModifier` or `ResponseHeaderModifier`. Don't use redirect or rewrite filters here: they apply to all Lightrun traffic. |
| `annotations`, `labels` | `{}` | Added to the `HTTPRoute` objects. |
| `http_redirect.enabled` | `true` | Render a second `HTTPRoute` (`<release>-router-http-redirect`) that redirects HTTP to HTTPS with a 301. |
| `http_redirect.parentRefs` | `[]` | HTTP listener(s) of an existing Gateway. If empty, the redirect route is rendered only when the chart creates the Gateway with its default listeners. |
| `gateway.create` | `false` | Create a `Gateway` named `<release>-router` in the release namespace. |
| `gateway.gatewayClassName` | `""` | Required when `gateway.create` is `true`. |
| `gateway.listeners` | `[]` | Replaces the default listeners. The defaults are `https` on 443, which terminates TLS with the certificate from the `certificate` section, and `http` on 80 when `http_redirect.enabled` is `true`. If you set this, also set `parentRefs` and `http_redirect.parentRefs` to match your listener names. |
| `gateway.addresses`, `gateway.infrastructure` | empty | Passed through to the `Gateway` spec, for example to request a static IP or to add annotations to the generated load balancer Service. |
| `gateway.annotations`, `gateway.labels` | `{}` | Added to the `Gateway`. |
| `backend_tls_policy.enabled` | `true` | Render a `BackendTLSPolicy` for the router Service when the router serves HTTPS. |
| `backend_tls_policy.api_version` | `""` | Auto-detected: `gateway.networking.k8s.io/v1`, then `v1alpha3`. |
| `backend_tls_policy.hostname` | `""` | SNI and the name the router certificate is validated against. If empty, `general.lightrun_endpoint` is used. |
| `backend_tls_policy.ca_certificate` | `""` | PEM of the CA that signed the router certificate. The chart stores it in the ConfigMap `<release>-router-backend-ca`. |
| `backend_tls_policy.caCertificateRefs` | `[]` | Existing ConfigMaps (key `ca.crt`) to validate the router certificate with. |
| `backend_tls_policy.wellKnownCACertificates` | `""` | Set to `System` when the certificate is publicly trusted. |
| `backend_tls_policy.subjectAltNames` | `[]` | Names the router certificate must contain, for example `[{type: Hostname, hostname: lightrun.example.com}]`. Set this on Istio-based gateways, including OpenShift: they check the certificate chain but verify the router's identity only through this field. They use `hostname` for SNI only. |

When the router serves HTTPS, exactly one of `ca_certificate`, `caCertificateRefs` or `wellKnownCACertificates` is required. If you set `ca_certificate` and `caCertificateRefs` together, both are added to the policy.

The `HTTPRoute` points to the router Service on port `general.router.service.ports.https` when the router serves HTTPS. Otherwise it uses `general.router.service.ports.http`. `general.router.service.enabled` must stay `true`.

## Choose a TLS topology
##### 1 - Gateway TLS <> Lightrun Router Non-SSL (most portable)
>The Gateway terminates TLS on port 443 and forwards plain HTTP to the router on port 8080. It needs no BackendTLSPolicy and works with every implementation, including OpenShift 4.19–4.21 and the AWS Load Balancer Controller.

Example with a Gateway created by the chart:
```yaml
general:
  lightrun_endpoint: lightrun.example.com
  router:
    tls:
      enabled: false
    ingress:
      enabled: false
    gateway_api:
      enabled: true
      timeouts:
        request: "600s"
      gateway:
        create: true
        gatewayClassName: eg
certificate:
  existing_cert: lightrun-tls
```
The Gateway listener reads the TLS certificate from the `certificate` section, the same Secret that the Ingress uses.

##### 2 - Gateway TLS <> Lightrun Router SSL (end-to-end TLS)
>The Gateway terminates TLS, then opens a new TLS connection to the router on port 8443. It validates the router certificate through a BackendTLSPolicy. This topology is required when `general.internal_tls.enabled` is `true`.

Example with an existing Gateway managed by the cluster admin:
```yaml
general:
  lightrun_endpoint: lightrun.example.com
  router:
    tls:
      enabled: true
    ingress:
      enabled: false
    gateway_api:
      enabled: true
      parentRefs:
        - name: shared-gateway
          namespace: gateway-system
          sectionName: https
      http_redirect:
        parentRefs:
          - name: shared-gateway
            namespace: gateway-system
            sectionName: http
      backend_tls_policy:
        # PEM of the CA that signed the certificate in the `certificate` section.
        # Use `wellKnownCACertificates: System` for publicly trusted certificates.
        ca_certificate: |
          -----BEGIN CERTIFICATE-----
          ...
          -----END CERTIFICATE-----
```
An existing Gateway must accept routes from the Lightrun namespace through `allowedRoutes.namespaces` on its listeners. Its listener terminates TLS with a certificate that the cluster admin manages. The Lightrun namespace does not need a `ReferenceGrant`, because the `HTTPRoute` and the router Service are in the same namespace.

> [!NOTE]
> TLS passthrough to the router (`TLSRoute`) is not provided by the chart. It is only in the experimental channel on most platforms.

## Portability
The `Gateway`, `HTTPRoute` (path match, backendRefs, `RequestRedirect`) and WebSocket upgrades are core Gateway API features and work in every conformant implementation. These parts vary by platform:

| Platform / implementation | BackendTLSPolicy (topology 2) | `HTTPRoute` timeouts | Default request timeout | Default max request body |
|---|---|---|---|---|
| Envoy Gateway (v1.6+) | `v1` | supported | **15s** (Envoy default) | no limit |
| NGINX Gateway Fabric (v2.x) | `v1` (one CA ref) | **ignored** (route reports `UnsupportedField`) | 60s (nginx default) | **1m** |
| Istio (v1.28+) | `v1` (`v1alpha3` in 1.26/1.27) | supported | none | no limit |
| OpenShift 4.19–4.21 | **not available** | supported (Istio based) | | |
| OpenShift 4.22+ / 5.x (tested on 5.0.1, Gateway API v1.5.1) | `v1`. Set `subjectAltNames`; `hostname` alone is not verified. | supported | | no limit |
| GKE Gateway controller | `v1`. Also set `appProtocol: HTTPS` on the Service port, which this chart does not set, so prefer topology 1 | supported | 30s (backend service default) | |
| AWS Load Balancer Controller (Gateway API, ALB) | **not supported**. Use topology 1, or a `TargetGroupConfiguration` with HTTPS and no validation. | **not supported** (use the ALB idle timeout) | 60s idle timeout | no limit |
| AKS (Application Routing Gateway API / Istio add-on) | `v1` from Gateway API v1.4 (AKS 1.35+) | supported | | no limit |
| AKS Application Gateway for Containers | uses its own `alb.networking.azure.io` BackendTLSPolicy, use topology 1 | | | |

The router itself accepts request bodies of up to 50m. It applies its own upstream timeouts: the nginx default of 60s, and `general.router.mcp_endpoint.timeout_seconds` (600s) for `/mcp`. The Gateway must not be stricter than the router.

## Timeouts and body size
With the Ingress NGINX controller, these settings were annotations (`proxy-read-timeout`, `proxy-body-size`). Gateway API has no portable field for the body size, and timeout support varies. Configure them per implementation:

**Envoy Gateway.** Set `general.router.gateway_api.timeouts.request: "600s"`. Without it, requests running longer than 15s (for example `/mcp`) fail with a 504. Envoy Gateway doesn't limit the body size by default.

**NGINX Gateway Fabric.** NGF ignores `HTTPRoute` timeouts, limits request bodies to 1m and uses nginx's default proxy buffer size. Create these policies in the Lightrun namespace (the route name is `<release>-router`):
```yaml
apiVersion: gateway.nginx.org/v1alpha1
kind: ClientSettingsPolicy
metadata:
  name: lightrun-router
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: lightrun-router
  body:
    maxSize: 50m
---
apiVersion: gateway.nginx.org/v1alpha1
kind: ProxySettingsPolicy
metadata:
  name: lightrun-router
spec:
  targetRefs:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      name: lightrun-router
  timeout:
    read: 600s
    send: 600s
  buffering:
    bufferSize: 8k
```
`bufferSize: 8k` matches the `proxy-buffer-size: "8k"` that the chart adds for Ingress NGINX. Without it, large Keycloak response headers can make nginx return 502.

**Istio, OpenShift, AKS (Istio).** Set `timeouts.request: "600s"` if your mesh defines a default route timeout. Istio doesn't limit the body size by default.

**Other implementations.** Check the vendor documentation for the request timeout and the maximum body size. Then apply the equivalent of a 600s timeout and a 50m body limit to the `<release>-router` HTTPRoute.

## Examples by platform
Each platform below uses the Gateway API implementation that most clusters on it run. That is the platform's own managed implementation where one exists, and Envoy Gateway on self-managed clusters. The chart renders the same generic resources everywhere; only the values and the platform's own configuration objects differ.

All examples set `ingress.enabled: false`. During a migration, keep it `true` until DNS points to the Gateway (see [Migrating from Ingress NGINX](#migrating-from-ingress-nginx)). `certificate.existing_cert` is the TLS Secret the chart already uses for the Ingress.

| Platform | Implementation | Router TLS | Status |
|---|---|---|---|
| Vanilla Kubernetes / kubespray | Envoy Gateway | end-to-end (BackendTLSPolicy) | tested (kind, kubespray v2.32 defaults) |
| OpenShift 4.19–4.21 | OpenShift Gateway API (Ingress Operator) | Gateway only | tested (ROSA 4.20.46) |
| OpenShift 4.22+ / 5.x | OpenShift Gateway API (Ingress Operator) | end-to-end (BackendTLSPolicy) | tested (ROSA 5.0.1) |
| Amazon EKS | AWS Load Balancer Controller, ALB Gateway | Gateway only, or HTTPS to the router without validation | tested (EKS 1.36, LBC v3.6.2) |
| Azure AKS | Application Routing Gateway API (Istio-based) | end-to-end (BackendTLSPolicy) | tested (AKS 1.36) |

### Vanilla Kubernetes / kubespray: Envoy Gateway
Requires Envoy Gateway and its GatewayClass, named `eg` here.
```yaml
general:
  lightrun_endpoint: lightrun.example.com
  router:
    tls:
      enabled: true
    ingress:
      enabled: false
    gateway_api:
      enabled: true
      timeouts:
        request: "600s"
      gateway:
        create: true
        gatewayClassName: eg
      backend_tls_policy:
        ca_certificate: |
          -----BEGIN CERTIFICATE-----
          ...CA that signed the Lightrun certificate...
          -----END CERTIFICATE-----
certificate:
  existing_cert: lightrun-tls
```
* `timeouts.request` is required. Envoy Gateway ends requests after 15s by default.
* With NetworkPolicy enabled, add `envoy-gateway-system` to `general.networkPolicy.ingress.namespacesSelector`.

### OpenShift: OpenShift Gateway API (Ingress Operator)
Requires the OpenShift GatewayClass, usually named `openshift-default`.
**OpenShift 4.19–4.21** (no BackendTLSPolicy, so the router stays on plain HTTP):
```yaml
general:
  openshift: true
  lightrun_endpoint: lightrun.apps.<cluster-domain>
  router:
    tls:
      enabled: false
    ingress:
      enabled: false
    gateway_api:
      enabled: true
      timeouts:
        request: "600s"
      gateway:
        create: true
        gatewayClassName: openshift-default
certificate:
  existing_cert: lightrun-tls
```
**OpenShift 4.22+ / 5.x** (end-to-end TLS):
```yaml
general:
  openshift: true
  lightrun_endpoint: lightrun.apps.<cluster-domain>
  router:
    tls:
      enabled: true
    ingress:
      enabled: false
    gateway_api:
      enabled: true
      timeouts:
        request: "600s"
      gateway:
        create: true
        gatewayClassName: openshift-default
      backend_tls_policy:
        wellKnownCACertificates: System
        subjectAltNames:
          - type: Hostname
            hostname: lightrun.apps.<cluster-domain>
certificate:
  existing_cert: lightrun-tls
```
* `subjectAltNames` is required for the router identity to be checked. The OpenShift gateway uses `hostname` only for SNI.
* Use `wellKnownCACertificates: System` for publicly trusted certificates. For a private CA, use `ca_certificate`.
* The Gateway gets its own load balancer, so `general.lightrun_endpoint` must resolve to the Gateway address, not to the default router.
* Without permission to create Gateways in the namespace, attach to an admin-managed Gateway with `parentRefs` instead of `gateway.create`.

### Amazon EKS: AWS Load Balancer Controller (ALB Gateway)
Tested with EKS 1.36, AWS Load Balancer Controller v3.6.2 and the Gateway API v1.6.0 standard CRDs. Requires the AWS Load Balancer Controller with Gateway API support and a GatewayClass with `controllerName: gateway.k8s.aws/alb`, named `aws-alb` here.

Some ALB limits shape this setup:
* ALB can't read the TLS certificate from a Kubernetes Secret (`certificateRefs`), so the HTTPS listener has no `tls` block. The certificate comes from ACM through a `LoadBalancerConfiguration`.
* `HTTPRoute.timeouts` is not supported. Raise the ALB idle timeout instead.
* `BackendTLSPolicy` is not supported, so keep the router on plain HTTP.
```yaml
general:
  router:
    tls:
      enabled: false
    ingress:
      enabled: false
    gateway_api:
      enabled: true
      gateway:
        create: true
        gatewayClassName: aws-alb
        infrastructure:
          parametersRef:
            group: gateway.k8s.aws
            kind: LoadBalancerConfiguration
            name: lightrun-alb
        listeners:
          - name: https
            protocol: HTTPS
            port: 443
            hostname: lightrun.example.com
            allowedRoutes:
              namespaces:
                from: Same
          - name: http
            protocol: HTTP
            port: 80
            hostname: lightrun.example.com
            allowedRoutes:
              namespaces:
                from: Same
      parentRefs:
        - name: lightrun-router
          sectionName: https
      http_redirect:
        parentRefs:
          - name: lightrun-router
            sectionName: http
```
Create these in the Lightrun namespace:
```yaml
apiVersion: gateway.k8s.aws/v1
kind: LoadBalancerConfiguration
metadata:
  name: lightrun-alb
spec:
  scheme: internet-facing
  listenerConfigurations:
    - protocolPort: HTTPS:443
      defaultCertificate: arn:aws:acm:<region>:<account>:certificate/<id>
  loadBalancerAttributes:
    - key: idle_timeout.timeout_seconds
      value: "600"
---
apiVersion: gateway.k8s.aws/v1
kind: TargetGroupConfiguration
metadata:
  name: lightrun-router
spec:
  targetReference:
    name: lightrun-router
  defaultConfiguration:
    targetType: ip
    healthCheckConfig:
      healthCheckPath: /health
```
To keep HTTPS between the ALB and the router, set `router.tls.enabled: true`, `gateway_api.backend_tls_policy.enabled: false`, and in the `TargetGroupConfiguration` set `protocol: HTTPS` and `healthCheckConfig.healthCheckProtocol: HTTPS`. The ALB then encrypts traffic to the router but doesn't validate the router certificate.
* For a load balancer reachable only from your network, set `scheme: internal` in the `LoadBalancerConfiguration`.
* The ALB adds the port to the redirect target (`Location: https://<host>:443/...`). Browsers handle this normally.

### Azure AKS: Application Routing Gateway API (Istio-based)
Tested with AKS 1.36. Requires the Application Routing Gateway API add-on, which provides the GatewayClass `approuting-istio`. Its Gateway API CRDs (v1.5.1 on AKS 1.36) include BackendTLSPolicy v1, so the router can stay on TLS:
```yaml
general:
  lightrun_endpoint: lightrun.example.com
  router:
    tls:
      enabled: true
    ingress:
      enabled: false
    gateway_api:
      enabled: true
      timeouts:
        request: "600s"
      gateway:
        create: true
        gatewayClassName: approuting-istio
      backend_tls_policy:
        ca_certificate: |
          -----BEGIN CERTIFICATE-----
          ...CA that signed the Lightrun certificate...
          -----END CERTIFICATE-----
        subjectAltNames:
          - type: Hostname
            hostname: lightrun.example.com
certificate:
  existing_cert: lightrun-tls
```
* `subjectAltNames` is required for the router identity to be checked, as on OpenShift. With a wrong name the gateway returns 503.
* Use `wellKnownCACertificates: System` instead of `ca_certificate` for publicly trusted certificates.
* To keep the router on plain HTTP, set `router.tls.enabled: false` and drop `backend_tls_policy`.
* For an internal Azure load balancer, add `service.beta.kubernetes.io/azure-load-balancer-internal: "true"` under `gateway.infrastructure.annotations`.
* Microsoft documents that this implementation doesn't support request header or body size limits.

## Network policy
When `general.networkPolicy.ingress.enabled` is `true`, add the namespace where the Gateway's data-plane pods run to `general.networkPolicy.ingress.namespacesSelector`. Otherwise the Gateway can't reach the router and returns 503. The namespace depends on the implementation:
* Envoy Gateway: `envoy-gateway-system`, by default
* NGINX Gateway Fabric: the Gateway's namespace
* Istio: the Gateway's namespace
* OpenShift: `openshift-ingress`

```yaml
general:
  networkPolicy:
    enabled: true
    ingress:
      enabled: true
      namespacesSelector: ["envoy-gateway-system"]
```

## OpenShift
`general.openshift: true` keeps its current behaviour. While `general.router.ingress.enabled` is `true`, the chart renders the Ingress, which OpenShift converts to a Route.

Gateway API support by OpenShift version:

| OpenShift | Gateway API | With this chart |
|---|---|---|
| 4.14–4.18 | Not shipped by OpenShift | Keep the Ingress/Route. If `gateway_api.enabled` is set, the install fails because the CRDs are missing. |
| 4.19–4.21 | v1.2.1 / v1.3.0 standard, no BackendTLSPolicy | Topology 1 only (router on plain HTTP). Tested on ROSA 4.20.46. With router TLS on, the install fails with a clear message and the release is not changed. |
| 4.22+ / 5.x | v1.4+ standard, including BackendTLSPolicy | Topology 1 or 2. Tested on ROSA 5.0.1. |

To use the OpenShift Gateway API instead (OpenShift 4.19+):
1. The cluster must have the OpenShift `GatewayClass`, usually named `openshift-default`.
2. Then use one of these:
   * `gateway.create: true` with `gateway.gatewayClassName: openshift-default`. The Gateway and its Envoy proxy pods are created in the Lightrun namespace, together with a `LoadBalancer` Service, which is an ELB on ROSA. You need permission to create Gateways in the namespace.
   * `parentRefs` pointing to a Gateway that the cluster admin manages, for example in `openshift-ingress`. You only need permission to create `HTTPRoute`s.
3. On OpenShift 4.19–4.21 the `BackendTLSPolicy` CRD is not available. Use [topology 1](#1---gateway-tls--lightrun-router-non-ssl-most-portable) (`general.router.tls.enabled: false`, `general.internal_tls.enabled: false`).
4. On OpenShift 4.22+ and 5.x you can use topology 2. Set `backend_tls_policy.subjectAltNames` to the router hostname as well: the OpenShift gateway checks the certificate chain, but verifies the hostname only through `subjectAltNames`.

See [Examples by platform](#openshift-openshift-gateway-api-ingress-operator) for tested values for both version ranges.

`general.openshift_embeded_hostname` only applies to the Ingress/Route path.

## Rendering without cluster access
`helm template` and some GitOps tools render without cluster access, so the CRD check can't see what the cluster has. Use one of these options:
* Pass the API versions explicitly, for example:
  `helm template ... --api-versions gateway.networking.k8s.io/v1/HTTPRoute --api-versions gateway.networking.k8s.io/v1/Gateway --api-versions gateway.networking.k8s.io/v1/BackendTLSPolicy`
* Set `general.router.gateway_api.validate_crds: false`. `BackendTLSPolicy` then defaults to `v1`. Use `backend_tls_policy.api_version` to override it.

Argo CD passes the cluster's API versions to Helm, so it needs neither option.

## Migrating from Ingress NGINX
The Ingress and the Gateway API resources are controlled by separate flags, so you can migrate with no downtime:

1. **Check the prerequisites.** Confirm the cluster meets the [prerequisites](#prerequisites) and note the `GatewayClass` name (`kubectl get gatewayclass`).
2. **Map your Ingress annotations.**

   | Ingress NGINX annotation | Gateway API equivalent |
   |---|---|
   | `backend-protocol: "HTTPS"` (added automatically when the router serves HTTPS) | `BackendTLSPolicy`, rendered by the chart (`backend_tls_policy.*`), or switch to topology 1 |
   | `proxy-read-timeout` / `proxy-send-timeout` | `gateway_api.timeouts` or an implementation policy, see [Timeouts and body size](#timeouts-and-body-size) |
   | `proxy-body-size` | implementation policy (NGF `ClientSettingsPolicy`, Envoy Gateway `BackendTrafficPolicy.requestBuffer`) |
   | `proxy-buffer-size: "8k"` (added automatically) | not needed. The router sets its own buffers. |
   | `ssl-redirect` / `force-ssl-redirect` | `http_redirect.enabled` |
   | `whitelist-source-range` | `general.router.acl.*` (enforced by the router, independent of the controller) |
   | `ingressClassName` | `gateway.gatewayClassName` or `parentRefs` |
3. **Enable Gateway API next to the existing Ingress.** Leave `general.router.ingress.enabled: true` for now:
   ```yaml
   general:
     router:
       gateway_api:
         enabled: true
         timeouts:
           request: "600s"
         gateway:
           create: true
           gatewayClassName: <your-class>
   ```
   Run `helm upgrade` with your values file. This adds the Gateway API resources, keeps the Ingress, and doesn't restart the router.
4. **Verify the new path before you switch DNS.**
   ```shell
   kubectl -n <namespace> get gateway,httproute,backendtlspolicy
   # Accepted=True and Programmed=True on the Gateway, Accepted=True and ResolvedRefs=True on the routes and the policy
   GW_IP=$(kubectl -n <namespace> get gateway <release>-router -o jsonpath='{.status.addresses[0].value}')
   curl --resolve <lightrun_endpoint>:443:$GW_IP https://<lightrun_endpoint>/
   ```
5. **Switch DNS** for `general.lightrun_endpoint` to the Gateway address. Wait for the old record's TTL to expire.
6. **Remove the Ingress.** Set `general.router.ingress.enabled: false` and run `helm upgrade` again.

To roll back, set `general.router.ingress.enabled: true` again, or run `helm rollback`, and point DNS back to the Ingress controller.

> [!NOTE]
> If you upgrade with `--reuse-values` from a chart version that has no `gateway_api` section, pass the Gateway API keys with `--set` or `-f`. Missing keys fall back to the defaults listed above.

## Troubleshooting
* **The chart fails with "Gateway API CRDs ... are not installed".** The cluster doesn't meet the [prerequisites](#prerequisites). When rendering without cluster access, see [Rendering without cluster access](#rendering-without-cluster-access).
* **The chart fails with "the BackendTLSPolicy CRD ... is not installed".** Use topology 1 (`general.router.tls.enabled: false`), or set `backend_tls_policy.enabled: false` if your implementation handles backend TLS another way.
* **A wrong `hostname` is still accepted** (Istio, OpenShift). These implementations verify the router's identity only through `backend_tls_policy.subjectAltNames`, so set it.
* **502/503 from the Gateway with topology 2.** The `BackendTLSPolicy` CA or hostname doesn't match the router certificate. The certificate must include `backend_tls_policy.hostname` (by default `general.lightrun_endpoint`) in its SAN. If the policy is fine, a NetworkPolicy may be blocking the Gateway. See [Network policy](#network-policy).
* **504 after about 15 seconds** (Envoy Gateway). Set `timeouts.request`.
* **413 on uploads** (NGINX Gateway Fabric). Add the `ClientSettingsPolicy` above.
* **The Gateway stays `Programmed=False`.** The implementation couldn't get an address for it. Check the Gateway status conditions. `gateway.infrastructure` and `gateway.addresses` are passed through if your implementation needs them.
