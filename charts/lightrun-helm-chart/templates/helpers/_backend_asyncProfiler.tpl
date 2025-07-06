{{- define "lightrun-backend.initContainer.download-async-profiler" -}}
{{- if .Values.deployments.backend.asyncProfiler.enabled -}}  
{{ include "asyncProfiler.initContainer.download-async-profiler" .Values.deployments.backend.asyncProfiler }}
  securityContext: {{- include "lightrun-be.containerSecurityContext" . | indent 4 }}
{{- end -}}
{{- end -}}


{{- define "lightrun-backend.container.persist-async-profiler-output-files" -}}
{{- if and .Values.deployments.backend.asyncProfiler.enabled .Values.deployments.backend.asyncProfiler.persistence.enabled }}  
{{ include "asyncProfiler.container.persist-async-profiler-output-files" . }}
  securityContext: {{- include "lightrun-be.containerSecurityContext" . | indent 4 }}
{{- end -}}
{{- end -}}


{{- define "lightrun-backend.volumes.asyncProfiler" -}}
{{- if .Values.deployments.backend.asyncProfiler.enabled -}}  
{{ include "asyncProfiler.volumes" .Values.deployments.backend.asyncProfiler }}
{{- end -}}
{{- end -}}


{{- define "lightrun-backend.volumeMounts.asyncProfiler" -}}
{{- if .Values.deployments.backend.asyncProfiler.enabled }} 
{{- include "asyncProfiler.volumeMounts" . }}
{{- end -}}
{{- end -}}


{{- define "lightrun-backend.java.argument.asyncProfiler" -}}
{{- if .Values.deployments.backend.asyncProfiler.enabled -}}  
"{{- include "asyncProfiler.java.agentpath" .Values.deployments.backend.asyncProfiler -}}",
{{- end -}}
{{- end -}}

