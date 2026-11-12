# Kubernetes Gateway API
This section configures the **Lightrun Router** with the **[Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)**, the successor to the Ingress API.

The chart renders an `HTTPRoute` that sends all traffic for `general.lightrun_endpoint` to the Lightrun Router Service. The route can attach to a Gateway that your cluster admin already runs, or to a `Gateway` that the chart creates. When the router serves HTTPS, the chart also renders a `BackendTLSPolicy` so that the Gateway connects to the router over TLS and validates its certificate.

Gateway API support is **disabled by default**. Existing installations don't change until you set `general.router.gateway_api.enabled: true`.

## Prerequisites
The cluster must already provide:
1. **Gateway API CRDs** (`gateway.networking.k8s.io`), v1.2 or later, from the standard channel.
2. **A Gateway API implementation** (controller) and its `GatewayClass`, for example Envoy Gateway, NGINX Gateway Fabric, Istio, Cilium, the GKE Gateway controller, or the AWS Load Balancer Controller.
3. **Only if the router serves HTTPS** (`general.router.tls.enabled` or `general.internal_tls.enabled`): the `BackendTLSPolicy` CRD: `v1` (Gateway API v1.4+), or `v1alpha3` if you also set `backend_tls_policy.api_version: gateway.networking.k8s.io/v1alpha3`. Some platforms don't provide it.
4. A DNS record for `general.lightrun_endpoint` that points to the Gateway's external address.

## Configuration reference
All keys are under `general.router.gateway_api`:

| Key | Default | Description |
|---|---|---|
| `enabled` | `false` | Render the Gateway API resources. This is independent of `general.router.ingress.enabled`, so both can run side by side during a migration. |
| `parentRefs` | `[]` | Gateway(s) the `HTTPRoute` attaches to. Required unless `gateway.create` is `true`. |
| `hostnames` | `[]` | Hostnames on the `HTTPRoute`. If empty, `[general.lightrun_endpoint]` is used. |
| `timeouts` | `{}` | `HTTPRoute` rule timeouts (`request`, `backendRequest`). See [Timeouts and body size](#timeouts-and-body-size). |
| `filters` | `[]` | `HTTPRoute` rule filters, for example `RequestHeaderModifier` or `ResponseHeaderModifier`. Don't use redirect or rewrite filters here: they apply to all Lightrun traffic. |
| `annotations`, `labels` | `{}` | Added to the `HTTPRoute` objects. |
| `http_redirect.enabled` | `true` | Render a second `HTTPRoute` (`<release>-router-http-redirect`) that redirects HTTP to HTTPS with a 301. |
| `http_redirect.parentRefs` | `[]` | HTTP listener(s) of an existing Gateway. If empty, the redirect route is rendered only when the chart creates the Gateway with its default listeners. |
| `gateway.create` | `false` | Create a `Gateway` named `<release>-gateway` in the release namespace. |
| `gateway.gatewayClassName` | `""` | Required when `gateway.create` is `true`. |
| `gateway.listeners` | `[]` | Replaces the default listeners. The defaults are `https` on 443, which terminates TLS with the certificate from the `certificate` section, and `http` on 80 when `http_redirect.enabled` is `true`. If you set this, also set `parentRefs` and `http_redirect.parentRefs` to match your listener names. |
| `gateway.addresses`, `gateway.infrastructure` | empty | Passed through to the `Gateway` spec, for example to request a static IP or to add annotations to the generated load balancer Service. |
| `gateway.annotations`, `gateway.labels` | `{}` | Added to the `Gateway`. |
| `backend_tls_policy.enabled` | `true` | Render a `BackendTLSPolicy` for the router Service when the router serves HTTPS. |
| `api_version`, `gateway.api_version`, `backend_tls_policy.api_version` | `gateway.networking.k8s.io/v1` | apiVersion of the HTTPRoutes, the Gateway and the BackendTLSPolicy. For example, set `backend_tls_policy.api_version: gateway.networking.k8s.io/v1alpha3` on clusters that serve only that version. |
| `backend_tls_policy.hostname` | `""` | The hostname the Gateway requests when it opens the TLS connection to the router, and the name the router certificate is validated against. If empty, `general.lightrun_endpoint` is used. |
| `backend_tls_policy.ca_certificate` | `""` | PEM of the CA that signed the router certificate. The chart stores it in the ConfigMap `<release>-router-backend-ca`. |
| `backend_tls_policy.caCertificateRefs` | `[]` | Existing ConfigMaps (key `ca.crt`) to validate the router certificate with. |
| `backend_tls_policy.wellKnownCACertificates` | `false` | Set to `true` to trust the Gateway's system CA bundle, when the certificate is publicly trusted. |
| `backend_tls_policy.annotations`, `backend_tls_policy.labels` | `{}` | Added to the `BackendTLSPolicy`. Labels are also added to the CA ConfigMap. |
| `backend_tls_policy.subjectAltNames` | `[]` | Names the router certificate must contain, for example `[{type: Hostname, hostname: lightrun.example.com}]`. Set this on Istio-based gateways, including OpenShift: they check the certificate chain but verify the router's identity only through this field. They send `hostname` when connecting but don't validate the certificate against it. |

When the router serves HTTPS, set either a CA (`ca_certificate`, `caCertificateRefs`, or both, which are combined in the policy) or `wellKnownCACertificates: true`, not both.

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
        caCertificateRefs:
          - group: ""
            kind: ConfigMap
            name: lightrun-router-ca
```
`lightrun-router-ca` is a ConfigMap in the Lightrun namespace with the CA that signed the certificate in the `certificate` section, under the key `ca.crt`. For publicly trusted certificates, use `wellKnownCACertificates: true` instead.

On GKE, the Gateway uses HTTPS to the router only when the router Service declares it, so also set `general.router.service.annotations` to `cloud.google.com/app-protocols: '{"https":"HTTPS"}'`.

An existing Gateway must accept routes from the Lightrun namespace through `allowedRoutes.namespaces` on its listeners. Its listener must present the same certificate as the `certificate` section, because IDE plugins and agents pin that certificate. The Lightrun namespace does not need a `ReferenceGrant`, because the `HTTPRoute` and the router Service are in the same namespace.

> [!NOTE]
> TLS passthrough to the router (`TLSRoute`) is not provided by the chart. To let only the router handle TLS, expose the router Service as `type: LoadBalancer` instead of using a Gateway.

## Timeouts and body size
With Ingress NGINX, these are set through annotations (`proxy-read-timeout`, `proxy-body-size`). Gateway API has no portable field for the body size, and timeout support varies. Configure them per implementation:

**Envoy Gateway.** Set `general.router.gateway_api.timeouts.request: "600s"`. Without it, requests running longer than 15s (for example `/mcp`) fail with a 504. Envoy Gateway doesn't limit the body size by default.

**NGINX Gateway Fabric.** NGF ignores `HTTPRoute` timeouts, limits request bodies to 1 MB and uses nginx's default proxy buffer size. Create these policies in the Lightrun namespace (the route name is `<release>-router`; this example uses release `lightrun`):
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

All examples set `ingress.enabled: false`. During a migration, keep it `true` until DNS points to the Gateway. `certificate.existing_cert` is the TLS Secret the chart already uses for the Ingress.

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
        caCertificateRefs:
          - group: ""
            kind: ConfigMap
            name: lightrun-router-ca
certificate:
  existing_cert: lightrun-tls
```
* `lightrun-router-ca` is a ConfigMap in the Lightrun namespace with the CA that signed the Lightrun certificate, under the key `ca.crt`.
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
        wellKnownCACertificates: true
        subjectAltNames:
          - type: Hostname
            hostname: lightrun.apps.<cluster-domain>
certificate:
  existing_cert: lightrun-tls
```
* `subjectAltNames` is required for the router identity to be checked. The OpenShift gateway sends `hostname` when connecting to the router but doesn't validate the certificate against it.
* Use `wellKnownCACertificates: true` for publicly trusted certificates. For a private CA, use `caCertificateRefs` with a ConfigMap that holds the CA under `ca.crt`.
* The Gateway gets its own load balancer, so `general.lightrun_endpoint` must resolve to the Gateway address, not to the default router.
* Without permission to create Gateways in the namespace, attach to an admin-managed Gateway with `parentRefs` instead of `gateway.create`.

### Amazon EKS: AWS Load Balancer Controller (ALB Gateway)
Tested with EKS 1.36, AWS Load Balancer Controller v3.6.2 and the Gateway API v1.6.0 standard CRDs. Requires the AWS Load Balancer Controller with Gateway API support and a GatewayClass with `controllerName: gateway.k8s.aws/alb`, named `aws-alb` here.

Some ALB limits shape this setup:
* ALB can't read the TLS certificate from a Kubernetes Secret (`certificateRefs`), so the HTTPS listener has no `tls` block. The certificate comes from AWS Certificate Manager (ACM) through a `LoadBalancerConfiguration`, and it must be the Lightrun certificate from the `certificate` section imported into ACM, because IDE plugins and agents pin it. See [Import Certificate To ACM](aws_load_balancer_controller.md#import-certificate-to-aws-certificate-manager-acm).
* `HTTPRoute.timeouts` is not supported. Raise the ALB idle timeout instead.
* `BackendTLSPolicy` is not supported, so keep the router on plain HTTP.
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
        - name: lightrun-gateway
          sectionName: https
      http_redirect:
        parentRefs:
          - name: lightrun-gateway
            sectionName: http
```
This example assumes the release name `lightrun`: the chart names the Gateway `<release>-gateway` and the router Service `<release>-router`, so adjust `parentRefs` and `targetReference.name` below to your release name.

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
To keep HTTPS between the ALB and the router, set `general.router.tls.enabled: true`, `general.router.gateway_api.backend_tls_policy.enabled: false`, and in the `TargetGroupConfiguration` set `protocol: HTTPS` and `healthCheckConfig.healthCheckProtocol: HTTPS`. The ALB then encrypts traffic to the router but doesn't validate the router certificate.
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
        caCertificateRefs:
          - group: ""
            kind: ConfigMap
            name: lightrun-router-ca
        subjectAltNames:
          - type: Hostname
            hostname: lightrun.example.com
certificate:
  existing_cert: lightrun-tls
```
* `subjectAltNames` is required for the router identity to be checked, as on OpenShift. With a wrong name the gateway returns 503.
* `lightrun-router-ca` is a ConfigMap in the Lightrun namespace with the CA that signed the Lightrun certificate, under the key `ca.crt`. For publicly trusted certificates, use `wellKnownCACertificates: true` instead.
* To keep the router on plain HTTP, set `general.router.tls.enabled: false` and drop `backend_tls_policy`.
* For an internal Azure load balancer, add `service.beta.kubernetes.io/azure-load-balancer-internal: "true"` under `gateway.infrastructure.annotations`.
* Microsoft documents that this implementation doesn't support request header or body size limits.

## Network policy
When `general.networkPolicy.enabled` and `general.networkPolicy.ingress.enabled` are `true`, add the namespace where the Gateway's proxy pods run to `general.networkPolicy.ingress.namespacesSelector`. Otherwise the Gateway can't reach the router and returns 503. The namespace depends on the implementation:
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
| 4.14–4.18 | Not shipped by OpenShift | Keep the Ingress/Route. If `gateway_api.enabled` is `true`, the install fails because the CRDs are missing. |
| 4.19–4.21 | v1.2.1 / v1.3.0 standard, no BackendTLSPolicy | Topology 1 only (router on plain HTTP). Tested on ROSA 4.20.46. With router TLS on, the install fails because the cluster has no BackendTLSPolicy CRD. |
| 4.22+ / 5.x | v1.4+ standard, including BackendTLSPolicy | Topology 1 or 2. Tested on ROSA 5.0.1. |

To use the OpenShift Gateway API instead (OpenShift 4.19+):
1. The cluster must have the OpenShift `GatewayClass`, usually named `openshift-default`.
2. Then use one of these:
   * `gateway.create: true` with `gateway.gatewayClassName: openshift-default`. The Gateway and its Envoy proxy pods are created in the Lightrun namespace, together with a `LoadBalancer` Service, which is an AWS Elastic Load Balancer (ELB) on ROSA. You need permission to create Gateways in the namespace.
   * `parentRefs` pointing to a Gateway that the cluster admin manages, for example in `openshift-ingress`. You only need permission to create `HTTPRoute`s.
3. On OpenShift 4.19–4.21 the `BackendTLSPolicy` CRD is not available. Use [topology 1](#1---gateway-tls--lightrun-router-non-ssl-most-portable) (`general.router.tls.enabled: false`, `general.internal_tls.enabled: false`).
4. On OpenShift 4.22+ and 5.x you can use topology 2. Set `backend_tls_policy.subjectAltNames` to the router hostname as well: the OpenShift gateway checks the certificate chain, but verifies the hostname only through `subjectAltNames`.

See [Examples by platform](#openshift-openshift-gateway-api-ingress-operator) for tested values for both version ranges.

`general.openshift_embeded_hostname` only applies to the Ingress/Route path.

## Troubleshooting
* **`helm install` or `helm upgrade` fails with `no matches for kind "HTTPRoute"`, `"Gateway"` or `"BackendTLSPolicy"`.** The cluster doesn't meet the [prerequisites](#prerequisites). For `BackendTLSPolicy`, use topology 1 (`general.router.tls.enabled: false`), or set `backend_tls_policy.enabled: false` if your implementation handles backend TLS another way.
* **The Gateway accepts a router certificate that doesn't match `backend_tls_policy.hostname`** (Istio, OpenShift). These implementations verify the router's identity only through `backend_tls_policy.subjectAltNames`, so set it.
* **502/503 from the Gateway with topology 2.** The `BackendTLSPolicy` CA or hostname doesn't match the router certificate. The router certificate must list `backend_tls_policy.hostname` (by default `general.lightrun_endpoint`) among its Subject Alternative Names (SANs). If the policy is fine, a NetworkPolicy may be blocking the Gateway. See [Network policy](#network-policy).
* **504 after about 15 seconds** (Envoy Gateway). Set `timeouts.request`.
* **413 on uploads** (NGINX Gateway Fabric). Add the `ClientSettingsPolicy` above.
* **The Gateway stays `Programmed=False`.** The implementation couldn't get an address for it. Check the Gateway status conditions. `gateway.infrastructure` and `gateway.addresses` are passed through if your implementation needs them.
