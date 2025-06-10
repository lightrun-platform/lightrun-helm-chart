{{- define "lightrun-keycloak.initContainer.download-async-profiler" -}}
{{- if .Values.deployments.keycloak.asyncProfiler.enabled -}}  
{{ include "asyncProfiler.initContainer.download-async-profiler" .Values.deployments.keycloak.asyncProfiler }}
  securityContext: {{- include "lightrun-keycloak.containerSecurityContext" . | indent 4 }}
{{- end -}}
{{- end -}}


{{- define "lightrun-keycloak.container.persist-async-profiler-output-files" -}}
{{- if and .Values.deployments.keycloak.asyncProfiler.enabled .Values.deployments.keycloak.asyncProfiler.persistence.enabled }}  
{{ include "asyncProfiler.container.persist-async-profiler-output-files" . }}
  securityContext: {{- include "lightrun-keycloak.containerSecurityContext" . | indent 4 }}
{{- end -}}
{{- end -}}


{{- define "lightrun-keycloak.volumes.asyncProfiler" -}}
{{- if .Values.deployments.keycloak.asyncProfiler.enabled -}}  
{{ include "asyncProfiler.volumes" .Values.deployments.keycloak.asyncProfiler }}
{{- end -}}
{{- end -}}


{{- define "lightrun-keycloak.volumeMounts.asyncProfiler" -}}
{{- if .Values.deployments.keycloak.asyncProfiler.enabled }} 
{{- include "asyncProfiler.volumeMounts" . }}
{{- end -}}
{{- end -}}


{{- define "lightrun-keycloak.java.argument.asyncProfiler" -}}
{{- if .Values.deployments.keycloak.asyncProfiler.enabled -}}  
{{- include "asyncProfiler.java.agentpath" .Values.deployments.keycloak.asyncProfiler -}}
{{- end -}}
{{- end -}}

