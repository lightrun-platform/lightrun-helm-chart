
{{/*
Generate ca secret
*/}}

{{- define "internal-tls.gen-crt-with-ca" -}}
{{- $ca := genCA  ( printf "%s-ca" .Release.Name ) 365 -}}
ca.crt: {{ $ca.Cert | b64enc }}
{{ range (list (include "lightrun-be.name" $ ) (include "lightrun-fe.name" $ ) (include "lightrun-keycloak.name" $ ) (include "lightrun-redis.name" $ ) (include "lightrun-mq.name" $ ) (include "data_streamer.name" $ ) )}}
{{- $altNames := list . ( printf "%s.%s" . $.Release.Namespace ) ( printf "%s.%s.svc" . $.Release.Namespace ) -}}
{{- $cert := genSignedCert $.Release.Name nil $altNames 3650 $ca }}
{{ . }}.tls.crt: {{ $cert.Cert | b64enc | quote }}
{{ . }}.tls.key: {{ $cert.Key | b64enc | quote }}
{{- end }}
{{- end -}}


{{- define "internal-tls.gen-crt" -}}
{{- $ := index . 0 }}
{{- $svcName := index . 1 }}
{{- $altNames := list $svcName ( printf "%s.%s" $svcName $.Release.Namespace ) ( printf "%s.%s.svc" $svcName $.Release.Namespace ) -}}
{{- $cert := genSelfSignedCert $.Release.Name nil $altNames 3650 -}}
tls.crt: {{ $cert.Cert | b64enc | quote }}
tls.key: {{ $cert.Key | b64enc | quote }}
{{- end -}}


{{- define "http.scheme" -}}
{{- if .Values.general.internal_tls.enabled  -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}
