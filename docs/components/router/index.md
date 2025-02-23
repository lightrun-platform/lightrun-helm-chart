The Lightrun Router supports multiple deployment options across different cloud providers and ingress controllers. Choose the relevant setup based on your environment:
## Deployment Options
- [AWS Load Balancer Controller](aws_load_balancer_controller.md)
- [Azure Application Gateway](azure_app_gateway.md)
- [Azure Service Controller](azure_service_controller.md)
- [GCP GKE Ingress Controller](gcp_gke_ingress.md)
- [GCP GKE Service Controller](gcp_gke_service.md)
- [Nginx Ingress Controller](nginx_ingress.md)
- [Istio Gateway](istio_gateway.md)
- [Contour Ingress Controller](contour_ingress.md)
- [OpenShift HAProxy Router](openshift_haproxy.md)

## Access Control Lists (ACL)

The router allows defining IP-based access control for different endpoints. By default:
- All IPs **are allowed** unless explicitly denied.
- The **Keycloak admin endpoint** (`auth_admin`) and **metrics** (`metrics`) are **denied by default**.
```yaml
general:
  router:
    acl:
      # IP access list configuration
      # Expect list of CIDRs. For single ip, use /32
      # If `deny_ips` empty, all IPs are allowed
      global: # will affect all endpoints
        allow_ips: []
        deny_ips: []
      agents:
        allow_ips: []
        deny_ips: []
      auth_admin: #keycloak admin
        allow_ips: []
        deny_ips: ["all"]
      metrics:
        allow_ips: []
        deny_ips: ["all"]
```
## Rate Limiting

Rate limiting helps prevent excessive API requests. By default, it is **disabled**. 
The rate limit applies to all the requests to the router.
```yaml
general:
  router:
    rate_limit:
      global:
        enabled: false
        rps_per_ip: 50
        zone_size: 10m # size of the shared memory zone for rate limiting
```
## Custom Router Configuration

The router supports injecting custom Nginx configuration snippets for advanced tuning. By default, no additional configuration is applied.
```yaml
general:
	router:
    server_snippets: ""
    http_snippets: ""
```
### Example: Increasing Proxy Timeout

To extend timeout settings, update `server_snippets`:
```yaml
server_snippets: |
  proxy_connect_timeout   60s;
  proxy_send_timeout      60s;
  proxy_read_timeout      60s;
```
