# Keycloak Operator

Helm chart that installs Keycloak Custom Resource Definitions and optionally the Keycloak Operator.

## Installation

### Install CRDs only (default)
```bash
helm install keycloak-operator ./charts/lightrun-keycloak-operator
```

### Install CRDs + Operator
```bash
helm install keycloak-operator ./charts/lightrun-keycloak-operator \
  --set operator.enabled=true
```

## Configuration

**Note:** CRDs are always installed (they are located in the `crds/` folder and installed as prerequisites).

| Parameter | Description | Default |
|-----------|-------------|---------|
| `operator.enabled` | Install Keycloak Operator | `false` |
| `operator.image.repository` | Operator image repository | `quay.io/keycloak/keycloak-operator` |
| `operator.image.tag` | Operator image tag | `26.2.5` |
| `operator.image.pullPolicy` | Image pull policy | `IfNotPresent` |

## Usage as Dependency

```yaml
# Chart.yaml
dependencies:
  - name: lightrun-keycloak-operator
    version: "0.1.0"
    repository: "file://../lightrun-keycloak-operator"
    condition: general.keycloakOperator.enabled
```

## Source

Components from: https://github.com/keycloak/keycloak-k8s-resources (version 26.2.5) 