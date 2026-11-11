This section configures the **Lightrun Router** with the **[Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)**, the successor to the Ingress API.

The chart renders an `HTTPRoute` that sends all traffic for `general.lightrun_endpoint` to the Lightrun Router Service. The route can attach to a Gateway that your cluster admin already runs, or to a `Gateway` that the chart creates. When the router serves HTTPS, the chart also renders a `BackendTLSPolicy` so that the Gateway connects to the router over TLS and validates its certificate.

Gateway API support is **disabled by default**. Existing installations don't change until you set `general.router.gateway_api.enabled: true`.

# Prerequisites
1. **Gateway API CRDs** (`gateway.networking.k8s.io`), v1.2 or later, from the standard channel.
   * The CRDs are often preinstalled. kubespray installs them with `gateway_api_enabled: true` (v1.6.x standard channel in kubespray v2.32). They are also installed by OpenShift 4.19+, the AKS managed Gateway API add-on, and GKE.
   * To install them manually: `kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/<version>/standard-install.yaml`
2. **A Gateway API implementation** (controller) and its `GatewayClass`, for example Envoy Gateway, NGINX Gateway Fabric, Istio, Cilium, the GKE Gateway controller, or the AWS Load Balancer Controller. kubespray installs only the CRDs, not a controller.
3. **Only if the router serves HTTPS** (`general.router.tls.enabled` or `general.internal_tls.enabled`): the `BackendTLSPolicy` CRD.
   * It is in the standard channel from Gateway API **v1.4** as `v1`. Older releases ship it as `v1alpha3`, in the experimental channel only.
   * Some platforms don't ship it. See the [portability table](#portability).
4. A DNS record for `general.lightrun_endpoint` that points to the Gateway's external address.

The chart checks `.Capabilities.APIVersions` and fails with an explicit message when the required CRDs are missing. See [Rendering without cluster access](#rendering-without-cluster-access) for `helm template` and GitOps pipelines.

# Configuration reference
All keys are under `general.router.gateway_api`:

| Key | Default | Description |
|---|---|---|
| `enabled` | `false` | Render the Gateway API resources. This is independent of `general.router.ingress.enabled`, so both can run side by side during a migration. |
| `validate_crds` | `true` | Fail when the Gateway API CRDs are not found in the cluster. |
| `parentRefs` | `[]` | Gateway(s) the `HTTPRoute` attaches to. Required unless `gateway.create` is `true`. |
| `hostnames` | `[]` | Hostnames on the `HTTPRoute`. If empty, `[general.lightrun_endpoint]` is used. |
| `timeouts` | `{}` | `HTTPRoute` rule timeouts (`request`, `backendRequest`). See [Timeouts and body size](#timeouts-and-body-size). |
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

# Choose a TLS topology
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

# Portability
The `Gateway`, `HTTPRoute` (path match, backendRefs, `RequestRedirect`) and WebSocket upgrades are core Gateway API features and work in every conformant implementation. These parts vary by platform:

| Platform / implementation | BackendTLSPolicy (topology 2) | `HTTPRoute` timeouts | Default request timeout | Default max request body |
|---|---|---|---|---|
| Envoy Gateway (v1.6+) | `v1` | supported | **15s** (Envoy default) | no limit |
| NGINX Gateway Fabric (v2.x) | `v1` (one CA ref) | **ignored** (route reports `UnsupportedField`) | 60s (nginx default) | **1m** |
| Istio (v1.28+) | `v1` (`v1alpha3` in 1.26/1.27) | supported | none | no limit |
| kubespray (`gateway_api_enabled`) | CRD present (v1.6.x standard) | depends on the controller you install | depends | depends |
| OpenShift 4.19–4.21 | **not available** (CRDs locked by the ingress operator) | supported (Istio based) | | |
| OpenShift 4.22+ / 5.x (tested on 5.0.1, Gateway API v1.5.1) | `v1`. Set `subjectAltNames`; `hostname` alone is not verified. | supported | | no limit |
| GKE Gateway controller | `v1`. Also set `appProtocol: HTTPS` on the Service port, which this chart does not set, so prefer topology 1 | supported | 30s (backend service default) | |
| AWS Load Balancer Controller (Gateway API, ALB) | **not supported**. Use topology 1, or a `TargetGroupConfiguration` with HTTPS and no validation. | **not supported** (use the ALB idle timeout) | 60s idle timeout | no limit |
| AKS (managed Gateway API, Istio) | `v1` from Gateway API v1.4 (AKS 1.35+) | supported | | |
| AKS Application Gateway for Containers | uses its own `alb.networking.azure.io` BackendTLSPolicy, use topology 1 or create that object yourself | | | |

The router itself accepts request bodies of up to 50m. It applies its own upstream timeouts: the nginx default of 60s, and `general.router.mcp_endpoint.timeout_seconds` (600s) for `/mcp`. The Gateway must not be stricter than the router.

# Timeouts and body size
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

# Examples by platform
The chart renders only portable Gateway API resources. Implementation-specific settings, such as the class name, load balancer options and policies, are passed through values or created as separate objects.

All examples set `ingress.enabled: false`; during a migration, keep it `true` until DNS points to the Gateway. `certificate.existing_cert` is the TLS Secret the chart already uses for the Ingress. The examples are marked by how far they were tested:
* **tested:** installed and verified with this chart
* **docs-based:** written from the vendor documentation, verify on your cluster

### Vanilla Kubernetes / kubespray with Envoy Gateway (tested)
Tested with Envoy Gateway v1.10 on Kubernetes 1.34 and on a kubespray v2.32 equivalent: Calico 3.31, Gateway API v1.6.2 standard CRDs.
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
`timeouts.request` is required: Envoy Gateway ends requests after 15s by default. On bare metal (kubespray), the Gateway gets an external address only if a load balancer implementation such as MetalLB is installed.

### Vanilla Kubernetes / kubespray with NGINX Gateway Fabric, shared Gateway (tested)
Tested with NGF v2.8.1. The cluster admin owns the Gateway `shared` in `gateway-system`. Its listeners allow routes from the Lightrun namespace.
```yaml
general:
  router:
    tls:
      enabled: false
    ingress:
      enabled: false
    gateway_api:
      enabled: true
      parentRefs:
        - name: shared
          namespace: gateway-system
          sectionName: https
      http_redirect:
        parentRefs:
          - name: shared
            namespace: gateway-system
            sectionName: http
```
Also create the `ClientSettingsPolicy` and `ProxySettingsPolicy` from [Timeouts and body size](#timeouts-and-body-size).

### OpenShift 4.22+ / 5.x (tested on ROSA 5.0.1)
See [OpenShift](#openshift) for the tested values and the cluster-admin prerequisite. On OpenShift 4.19–4.21 use `router.tls.enabled: false` and leave out `backend_tls_policy`.

### Amazon EKS
With the AWS Load Balancer Controller (v2.14+) in Gateway API mode:
- **ALB Gateway** (`controllerName: gateway.k8s.aws/alb`) serves `HTTPRoute`, so it works with this chart.
- **NLB Gateway** (`controllerName: gateway.k8s.aws/nlb`) serves only L4 routes (`TCPRoute`, `UDPRoute`, `TLSRoute`). It can't serve the chart's `HTTPRoute`.

To use an NLB, put it in front of an L7 Gateway implementation such as Envoy Gateway or NGF. Their `LoadBalancer` Service becomes the NLB. Or expose the router Service directly as an NLB without Gateway API (see [AWS Load Balancer Controller](aws_load_balancer_controller.md)).

The controller enables its Gateway API support when it finds the Gateway API CRDs and its own CRDs (`LoadBalancerConfiguration`, `TargetGroupConfiguration`, `ListenerRuleConfiguration`). It only acts on GatewayClasses with its own `controllerName`, so existing Ingresses and Services are not affected.

**ALB Gateway (docs-based).** Some ALB limits shape this setup:
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
Create these in the Lightrun namespace. The GatewayClass `aws-alb` uses `controllerName: gateway.k8s.aws/alb` and is created once by the cluster admin.
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
To keep HTTPS between the ALB and the router, set `router.tls.enabled: true`, `gateway_api.backend_tls_policy.enabled: false` and `protocol: HTTPS` in the `TargetGroupConfiguration`. The ALB then encrypts traffic to the router but doesn't validate the router certificate.

**NLB in front of Envoy Gateway or NGF (docs-based).** Use the vanilla examples above, and pass NLB annotations to the generated Service:
```yaml
general:
  router:
    gateway_api:
      gateway:
        create: true
        gatewayClassName: eg
        infrastructure:
          annotations:
            service.beta.kubernetes.io/aws-load-balancer-type: "external"
            service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
            service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
```

### Google GKE (docs-based)
GKE's managed Gateway controller is enabled with `--gateway-api=standard`. HTTPS to backends needs `appProtocol: HTTPS` on the Service port, which the chart does not set, so keep the router on plain HTTP:
```yaml
general:
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
        gatewayClassName: gke-l7-global-external-managed
        addresses:
          - type: NamedAddress
            value: lightrun-static-ip
certificate:
  existing_cert: lightrun-tls
```
- Use `gke-l7-rilb` for an internal load balancer.
- Leave out `addresses` to get an ephemeral IP.
- The load balancer health-checks `/` by default. A `HealthCheckPolicy` (`networking.gke.io/v1`) that targets the router Service with `requestPath: /health` doesn't depend on the frontend.

### Azure AKS with the Istio add-on / managed Gateway API (docs-based)
```yaml
general:
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
        gatewayClassName: istio
certificate:
  existing_cert: lightrun-tls
```
- Check the class name with `kubectl get gatewayclass`.
- From AKS 1.35 (Gateway API v1.4+), you can switch to `router.tls.enabled: true` with `backend_tls_policy`. Also set `subjectAltNames`, as on [OpenShift](#openshift).

### Azure Application Gateway for Containers (docs-based)
It uses its own BackendTLSPolicy type, so keep the router on plain HTTP:
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
        gatewayClassName: azure-alb-external
        annotations:
          alb.networking.azure.io/alb-namespace: alb-infra
          alb.networking.azure.io/alb-name: alb-lightrun
certificate:
  existing_cert: lightrun-tls
```

# Network policy
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

# OpenShift
`general.openshift: true` keeps its current behaviour. While `general.router.ingress.enabled` is `true`, the chart renders the Ingress, which OpenShift converts to a Route.

Gateway API support by OpenShift version:

| OpenShift | Gateway API | With this chart |
|---|---|---|
| 4.14–4.18 | Not shipped by OpenShift | Keep the Ingress/Route. If `gateway_api.enabled` is set, the install fails because the CRDs are missing. |
| 4.19–4.21 | v1.2.1 / v1.3.0 standard, no BackendTLSPolicy. The CRDs are locked: adding BackendTLSPolicy is forbidden even for cluster-admin. | Topology 1 only (router on plain HTTP). Tested on ROSA 4.20.46. With router TLS on, the install fails with a clear message and the release is not changed. |
| 4.22+ / 5.x | v1.4+ standard, including BackendTLSPolicy | Topology 1 or 2. Tested on ROSA 5.0.1. |

To use the OpenShift Gateway API instead (OpenShift 4.19+):
1. A cluster-admin creates a `GatewayClass` once, usually named `openshift-default`, with `controllerName: openshift.io/gateway-controller/v1`. The Ingress Operator then deploys its Istio control plane in `openshift-ingress`.
2. Then use one of these:
   * `gateway.create: true` with `gateway.gatewayClassName: openshift-default`. The Gateway and its Envoy proxy pods are created in the Lightrun namespace, together with a `LoadBalancer` Service, which is an ELB on ROSA. You need permission to create Gateways in the namespace.
   * `parentRefs` pointing to a Gateway that the cluster admin manages, for example in `openshift-ingress`. You only need permission to create `HTTPRoute`s.
3. On OpenShift 4.19–4.21 the `BackendTLSPolicy` CRD is not available and can't be added. Use [topology 1](#1---gateway-tls--lightrun-router-non-ssl-most-portable) (`general.router.tls.enabled: false`, `general.internal_tls.enabled: false`).
4. On OpenShift 4.22+ and 5.x you can use topology 2. Set `backend_tls_policy.subjectAltNames` to the router hostname as well: the OpenShift gateway checks the certificate chain, but verifies the hostname only through `subjectAltNames`.

Example tested on ROSA 5.0.1 (topology 2, with the default `*.apps` Let's Encrypt certificate):
```yaml
general:
  openshift: true
  lightrun_endpoint: lightrun-lightrun.apps.<cluster-domain>
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
            hostname: lightrun-lightrun.apps.<cluster-domain>
certificate:
  existing_cert: certificates
```
The Gateway gets its own load balancer. The `*.apps` wildcard DNS still points to the default router, so create a DNS record for `general.lightrun_endpoint` that points to the Gateway address. With the default `*.apps` hostname, that is a more specific record in the cluster's DNS zone.

`general.openshift_embeded_hostname` only applies to the Ingress/Route path.

# Rendering without cluster access
`helm template` and some GitOps tools render without cluster access, so the CRD check can't see what the cluster has. Use one of these options:
* Pass the API versions explicitly, for example:
  `helm template ... --api-versions gateway.networking.k8s.io/v1/HTTPRoute --api-versions gateway.networking.k8s.io/v1/Gateway --api-versions gateway.networking.k8s.io/v1/BackendTLSPolicy`
* Set `general.router.gateway_api.validate_crds: false`. `BackendTLSPolicy` then defaults to `v1`. Use `backend_tls_policy.api_version` to override it.

Argo CD passes the cluster's API versions to Helm, so it needs neither option.

# Migrating from Ingress NGINX
The Ingress and the Gateway API resources are controlled by separate flags, so you can migrate with no downtime:

1. **Install the prerequisites.** Make sure the Gateway API CRDs and a controller are installed, and note the `GatewayClass` name (`kubectl get gatewayclass`).
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
7. **Uninstall Ingress NGINX** once no other application uses it.

To roll back, set `general.router.ingress.enabled: true` again, or run `helm rollback`, and point DNS back to the Ingress controller.

> [!NOTE]
> If you upgrade with `--reuse-values` from a chart version that has no `gateway_api` section, pass the Gateway API keys with `--set` or `-f`. Missing keys fall back to the defaults listed above.

# Troubleshooting
* **The chart fails with "Gateway API CRDs ... are not installed".** Install the CRDs, or see [Rendering without cluster access](#rendering-without-cluster-access).
* **The chart fails with "the BackendTLSPolicy CRD ... is not installed".** Use topology 1 (`general.router.tls.enabled: false`), install a Gateway API v1.4+ standard bundle, or set `backend_tls_policy.enabled: false` and configure backend TLS with your implementation's own resources, for example an Istio `DestinationRule`.
* **A wrong `hostname` is still accepted** (Istio, OpenShift). These implementations verify the router's identity only through `backend_tls_policy.subjectAltNames`, so set it.
* **502/503 from the Gateway with topology 2.** The `BackendTLSPolicy` CA or hostname doesn't match the router certificate. The certificate must include `backend_tls_policy.hostname` (by default `general.lightrun_endpoint`) in its SAN. If the policy is fine, a NetworkPolicy may be blocking the Gateway. See [Network policy](#network-policy).
* **504 after about 15 seconds** (Envoy Gateway). Set `timeouts.request`.
* **413 on uploads** (NGINX Gateway Fabric). Add the `ClientSettingsPolicy` above.
* **The Gateway stays `Programmed=False`.** The implementation couldn't get an address from its load balancer, for example on bare metal without MetalLB. Configure `gateway.infrastructure` or `gateway.addresses`, or use a NodePort per your implementation's documentation.
