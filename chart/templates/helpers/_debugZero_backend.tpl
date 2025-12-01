{{/*
Debug Zero Backend Helpers
*/}}

{{/*
Debug Zero Backend environment variables
*/}}
{{- define "debugZero.backend.env" -}}
env:
  - name: NODE_ENV
    value: {{ .Values.deployments.debugZero.backend.profile }}
  - name: REDIS_HOST
    value: {{ include "lightrun-redis.endpoint" . }}
  - name: REDIS_PORT
    value: {{ .Values.deployments.redis.port | quote }}
{{- if .Values.deployments.debugZero.backend.extraEnvs -}}
{{- toYaml .Values.deployments.debugZero.backend.extraEnvs | nindent 2 -}}
{{- end -}}
{{- end -}}

