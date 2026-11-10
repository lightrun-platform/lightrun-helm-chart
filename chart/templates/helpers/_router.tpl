{{- define "router.name" -}}
{{ include "lightrun.fullname" . }}-router
{{- end -}}




{{- define "router.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "router.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{- define "router.conf.name" -}}
{{ include "lightrun.fullname" . }}-router-conf
{{- end -}}


{{- define "router.use-tls" -}}
{{- if or
  .Values.general.internal_tls.enabled
  .Values.general.router.tls.enabled
-}}
{{- printf "true" -}}
{{- else -}}
{{- printf "false" -}}
{{- end -}}
{{- end -}}


{{- define "router.http.scheme" -}}
{{- if eq (include "router.use-tls" .) "true" -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}


{{- define "router.internal_tls_use_ca_cert" -}}
{{- if  and .Values.general.internal_tls.enabled .Values.general.internal_tls.certificates.verification .Values.general.internal_tls.certificates.existing_ca_secret_name -}}
proxy_ssl_verify on;
proxy_ssl_trusted_certificate /ca_cert/ca.crt;
{{- end -}}
{{- end -}}

{{- define "router.containerSecurityContext" -}}
{{/*Merge runAsUser to default SecurityContext*/}}
{{- $readOnlyRootFilesystem := dict "readOnlyRootFilesystem" (.Values.general.readOnlyRootFilesystem) -}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext $readOnlyRootFilesystem -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.router.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite $localSecurityContext (.Values.deployments.router.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.router.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.gateway.name" -}}
{{ include "router.name" . }}
{{- end -}}


{{- define "router.gateway_api.backend_ca.name" -}}
{{ include "router.name" . }}-backend-ca
{{- end -}}


{{- define "router.gateway_api.enabled" -}}
{{- if dig "router" "gateway_api" "enabled" false .Values.general -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.gateway.create" -}}
{{- if and (eq (include "router.gateway_api.enabled" .) "true") (dig "router" "gateway_api" "gateway" "create" false .Values.general) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.validate" -}}
{{- $gw := dig "router" "gateway_api" dict .Values.general -}}
{{- $create := eq (include "router.gateway_api.gateway.create" .) "true" -}}
{{- if not .Values.general.router.service.enabled -}}
{{- fail "general.router.gateway_api.enabled requires general.router.service.enabled: the HTTPRoute sends traffic to the router Service" -}}
{{- end -}}
{{- if and (not $create) (empty (dig "parentRefs" list $gw)) -}}
{{- fail "general.router.gateway_api.enabled requires general.router.gateway_api.parentRefs (the existing Gateway to attach the HTTPRoute to) or general.router.gateway_api.gateway.create: true" -}}
{{- end -}}
{{- if and $create (empty (dig "gateway" "gatewayClassName" "" $gw)) -}}
{{- fail "general.router.gateway_api.gateway.create requires general.router.gateway_api.gateway.gatewayClassName (see: kubectl get gatewayclass)" -}}
{{- end -}}
{{- if dig "validate_crds" true $gw -}}
{{- if not (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/HTTPRoute") -}}
{{- fail "general.router.gateway_api.enabled is true but the Gateway API CRDs (gateway.networking.k8s.io/v1 HTTPRoute) are not installed in the cluster. Install the Gateway API CRDs and a Gateway API implementation first. When rendering offline (helm template, GitOps), pass --api-versions gateway.networking.k8s.io/v1/HTTPRoute or set general.router.gateway_api.validate_crds: false" -}}
{{- end -}}
{{- if and $create (not (.Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/Gateway")) -}}
{{- fail "general.router.gateway_api.gateway.create is true but the Gateway API CRD gateway.networking.k8s.io/v1 Gateway is not installed in the cluster" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.backend_tls_policy.enabled" -}}
{{- if and (eq (include "router.gateway_api.enabled" .) "true") (eq (include "router.use-tls" .) "true") (dig "router" "gateway_api" "backend_tls_policy" "enabled" true .Values.general) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.backend_tls_policy.apiVersion" -}}
{{- $gw := dig "router" "gateway_api" dict .Values.general -}}
{{- $apiVersion := dig "backend_tls_policy" "api_version" "" $gw -}}
{{- if $apiVersion -}}
{{ $apiVersion }}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/BackendTLSPolicy" -}}
gateway.networking.k8s.io/v1
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha3/BackendTLSPolicy" -}}
gateway.networking.k8s.io/v1alpha3
{{- else if not (dig "validate_crds" true $gw) -}}
gateway.networking.k8s.io/v1
{{- else -}}
{{- fail "The router serves HTTPS (general.router.tls.enabled or general.internal_tls.enabled is true), so the Gateway must connect to it over TLS, but the BackendTLSPolicy CRD (gateway.networking.k8s.io v1 or v1alpha3) is not installed in the cluster. Either install it (Gateway API v1.4+ standard channel, or the experimental channel of older releases), set general.router.tls.enabled: false so the Gateway terminates TLS and talks plain HTTP to the router, or set general.router.gateway_api.backend_tls_policy.enabled: false and configure backend TLS with your implementation's own resources" -}}
{{- end -}}
{{- end -}}
