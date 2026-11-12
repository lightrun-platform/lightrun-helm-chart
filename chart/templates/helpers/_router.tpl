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
{{ include "lightrun.fullname" . }}-gateway
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
{{- end -}}


{{- define "router.gateway_api.backend_tls_policy.enabled" -}}
{{- if and (eq (include "router.gateway_api.enabled" .) "true") (eq (include "router.use-tls" .) "true") (dig "router" "gateway_api" "backend_tls_policy" "enabled" true .Values.general) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}


