{{- define "router.name" -}}
{{ .Release.Name }}-router
{{- end -}}




{{- define "router.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "router.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{- define "router.conf.name" -}}
{{ .Release.Name }}-router-conf
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
