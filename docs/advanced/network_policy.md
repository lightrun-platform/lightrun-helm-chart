# Network Policy

The **network policy** controls how pods communicate with each other and external networks. It defines ingress (incoming) and egress (outgoing) rules to regulate traffic based on namespaces, pods, IP addresses, and ports.

## Enabling Network Policies

To enable network policies, set:
```yaml
general:
  networkPolicy:
    enabled: true
```
## Policy Behavior

| Scenario                                             | Behavior                                              |
| ---------------------------------------------------- | ----------------------------------------------------- |
| `networkPolicy.enabled: false`                       | All traffic is **allowed** (no restrictions).         |
| `networkPolicy.ingress.enabled: false`               | All incoming traffic is **allowed**.                  |
| `networkPolicy.egress.enabled: false`                | All outgoing traffic is **allowed**.                  |
| `networkPolicy.ingress.enabled: true` + **no rules** | All incoming traffic is **denied**.                   |
| `networkPolicy.egress.enabled: true` + **no rules**  | All outgoing traffic is **denied**.                   |
| Defined `networkPolicy.ingress` rules                | Only **allowed sources** can access the service.      |
| Defined `networkPolicy.egress` rules                 | The service can **only access allowed destinations**. |
## Ingress Rules (Incoming Traffic)
Defines which external sources can access the pods.
- **`networkPolicy.ingress.enabled: false`**: No restrictions (all traffic allowed).
- **`networkPolicy.ingress.enabled: true` but no rules defined**: **All incoming traffic is denied.**
- To allow traffic, define one or more of:
    - **`namespacesSelector`**: Allow traffic from specific namespaces.
    - **`ipBlock`**: Allow traffic from specific IP ranges.
    - **`podSelector`**: Allow traffic from specific pods in the same namespace.
    - **`namespacePodSelector`**: Allow traffic from specific pods in specific namespaces.
    - **`ports`**: Allow traffic only on specific protocols and ports.
```yaml
general:
  networkPolicy:
    ingress:
      enabled: true  # Default: false (allow-all)
      namespacesSelector: ["example-namespace"]  # Allow traffic from these namespaces
      ipBlock:
      - cidr: 192.168.1.0/24  # Allow this CIDR range
        except:
        - 192.168.1.100/32  # Deny this specific IP
      podSelector:
        app.kubernetes.io/component: ["nginx", "backend"]  # Allow traffic from these pods in the same namespace
      namespacePodSelector:
        example-namespace:
          app.kubernetes.io/component: ["example-app"]  # Allow traffic from specific pods in selected namespaces
      ports:
      - protocol: TCP
        port: 80
        endPort: 8080  # Allow traffic to this port range (if supported)
```

## Egress Rules (Outgoing Traffic)
Defines where pods can send outbound traffic.

- **`networkPolicy.egress.enabled: false`**: No restrictions (all traffic allowed).
- **`networkPolicy.egress.enabled: true` but no rules defined**: **All outgoing traffic is denied.**
- To allow traffic, define one or more of:
    - **`namespacesSelector`**: Allow traffic to specific namespaces.
    - **`ipBlock`**: Allow traffic to specific IP ranges.
    - **`podSelector`**: Allow traffic to specific pods in the same namespace.
    - **`namespacePodSelector`**: Allow traffic to specific pods in specific namespaces.
    - **`ports`**: Allow traffic only on specific protocols and ports.
```yaml
general:
  networkPolicy:
    egress:
      enabled: true  # Default: false (allow-all)
      namespacesSelector: ["example-namespace"]  # Allow traffic to these namespaces
      ipBlock:
      - cidr: 10.0.0.0/16  # Allow traffic to this IP range
      podSelector:
        role: ["db"]  # Allow traffic only to database pods
      namespacePodSelector:
        example-namespace:
          app.kubernetes.io/component: ["example-app"]  # Allow traffic to specific pods in selected namespaces
      ports:
      - protocol: TCP
        port: 443  # Allow HTTPS traffic
```
