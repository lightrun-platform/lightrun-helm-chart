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


{{- define "router.gateway_api.defaults" -}}
enabled: false
api_version: gateway.networking.k8s.io/v1
parentRefs: []
hostnames: []
timeouts: {}
filters: []
annotations: {}
labels: {}
http_redirect:
  enabled: true
  parentRefs: []
gateway:
  create: false
  api_version: gateway.networking.k8s.io/v1
  gatewayClassName: ""
  listeners: []
  addresses: []
  infrastructure: {}
  annotations: {}
  labels: {}
backend_tls_policy:
  enabled: true
  api_version: gateway.networking.k8s.io/v1
  hostname: ""
  ca_certificate: ""
  caCertificateRefs: []
  wellKnownCACertificates: false
  subjectAltNames: []
  annotations: {}
  labels: {}
{{- end -}}


{{- define "router.gateway_api.config" -}}
{{- $config := dig "router" "gateway_api" dict .Values.general | deepCopy -}}
{{- range $key, $default := include "router.gateway_api.defaults" . | fromYaml -}}
{{- if not (hasKey $config $key) -}}
{{- $_ := set $config $key $default -}}
{{- else if kindIs "map" $default -}}
{{- $section := index $config $key -}}
{{- range $nestedKey, $nestedDefault := $default -}}
{{- if not (hasKey $section $nestedKey) -}}
{{- $_ := set $section $nestedKey $nestedDefault -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if not $config.hostnames -}}
{{- $_ := set $config "hostnames" (list .Values.general.lightrun_endpoint) -}}
{{- end -}}
{{- if not $config.backend_tls_policy.hostname -}}
{{- $_ := set $config.backend_tls_policy "hostname" .Values.general.lightrun_endpoint -}}
{{- end -}}
{{- toYaml $config -}}
{{- end -}}


{{- define "router.gateway_api.enabled" -}}
{{- $config := include "router.gateway_api.config" . | fromYaml -}}
{{- if $config.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.gateway.create" -}}
{{- $config := include "router.gateway_api.config" . | fromYaml -}}
{{- if and $config.enabled $config.gateway.create -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.http_redirect.enabled" -}}
{{- $config := include "router.gateway_api.config" . | fromYaml -}}
{{- $chartListener := and (eq (include "router.gateway_api.gateway.create" .) "true") (empty $config.gateway.listeners) -}}
{{- if and $config.enabled $config.http_redirect.enabled (or $config.http_redirect.parentRefs $chartListener) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.backend_tls_policy.enabled" -}}
{{- $config := include "router.gateway_api.config" . | fromYaml -}}
{{- if and $config.enabled (eq (include "router.use-tls" .) "true") $config.backend_tls_policy.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.backend_port" -}}
{{- if eq (include "router.use-tls" .) "true" -}}
{{ .Values.general.router.service.ports.https }}
{{- else -}}
{{ .Values.general.router.service.ports.http }}
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.parentRefs" -}}
{{- $config := include "router.gateway_api.config" . | fromYaml -}}
{{- if $config.parentRefs -}}
{{ toYaml $config.parentRefs }}
{{- else -}}
- name: {{ include "router.gateway_api.gateway.name" . }}
  sectionName: https
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.http_redirect.parentRefs" -}}
{{- $config := include "router.gateway_api.config" . | fromYaml -}}
{{- if $config.http_redirect.parentRefs -}}
{{ toYaml $config.http_redirect.parentRefs }}
{{- else -}}
- name: {{ include "router.gateway_api.gateway.name" . }}
  sectionName: http
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.gateway.listeners" -}}
{{- $config := include "router.gateway_api.config" . | fromYaml -}}
{{- if $config.gateway.listeners -}}
{{ toYaml $config.gateway.listeners }}
{{- else -}}
- name: https
  protocol: HTTPS
  port: 443
  hostname: {{ .Values.general.lightrun_endpoint | quote }}
  tls:
    mode: Terminate
    certificateRefs:
      - kind: Secret
        group: ""
        name: {{ include "secrets.certificate.name" . }}
  allowedRoutes:
    namespaces:
      from: Same
{{- if $config.http_redirect.enabled }}
- name: http
  protocol: HTTP
  port: 80
  hostname: {{ .Values.general.lightrun_endpoint | quote }}
  allowedRoutes:
    namespaces:
      from: Same
{{- end }}
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.backend_tls_policy.ca" -}}
{{- $policy := (include "router.gateway_api.config" . | fromYaml).backend_tls_policy -}}
{{- if or $policy.ca_certificate $policy.caCertificateRefs -}}
caCertificateRefs:
{{- if $policy.ca_certificate }}
  - group: ""
    kind: ConfigMap
    name: {{ include "router.gateway_api.backend_ca.name" . }}
{{- end }}
{{- with $policy.caCertificateRefs }}
{{ toYaml . | indent 2 }}
{{- end }}
{{- else -}}
wellKnownCACertificates: System
{{- end -}}
{{- end -}}


{{- define "router.gateway_api.validate" -}}
{{- $config := include "router.gateway_api.config" . | fromYaml -}}
{{- $create := eq (include "router.gateway_api.gateway.create" .) "true" -}}
{{- $policy := $config.backend_tls_policy -}}
{{- if not .Values.general.router.service.enabled -}}
{{- fail "general.router.gateway_api.enabled requires general.router.service.enabled: the HTTPRoute sends traffic to the router Service" -}}
{{- end -}}
{{- if and (not $create) (empty $config.parentRefs) -}}
{{- fail "general.router.gateway_api.enabled requires general.router.gateway_api.parentRefs (the existing Gateway to attach the HTTPRoute to) or general.router.gateway_api.gateway.create: true" -}}
{{- end -}}
{{- if and $create (empty $config.gateway.gatewayClassName) -}}
{{- fail "general.router.gateway_api.gateway.create requires general.router.gateway_api.gateway.gatewayClassName (see: kubectl get gatewayclass)" -}}
{{- end -}}
{{- if and (eq (include "router.gateway_api.backend_tls_policy.enabled" .) "true") (not (or $policy.ca_certificate $policy.caCertificateRefs $policy.wellKnownCACertificates)) -}}
{{- fail "general.router.gateway_api.backend_tls_policy needs a way to validate the router certificate: set ca_certificate (PEM of the CA that signed the certificate in the `certificate` section), caCertificateRefs, or wellKnownCACertificates: true" -}}
{{- end -}}
{{- end -}}
