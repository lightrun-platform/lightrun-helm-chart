{{/*
Get queue name by prefix from the queue_names list.

Parameters:
- prefix: The prefix to match against queue names
- Values: The chart values context
- strict (optional): If true, fail if no matching queue is found (default: false)

Returns:
- The first queue name that matches the prefix
- If no match found and strict=false, returns the first queue name
- If no match found and strict=true, fails the template
*/}}
{{- define "lightrun-mq.getQueueNameByPrefix" -}}
{{- $queue_names := .Values.general.mq.queue_names | default (list .Values.general.mq.queue_name) }}
{{- if not $queue_names }}
{{- fail "No queue names defined in general.mq.queue_names or general.mq.queue_name" }}
{{- end }}
{{- $prefix := .prefix | default "" | lower }}
{{- $strict := .strict | default false }}
{{- $matching_queue := "" }}
{{- range $queue_names }}
{{- if and . (hasPrefix $prefix (. | lower)) }}
{{- $matching_queue = . }}
{{- break }}
{{- end }}
{{- end }}
{{- if and $strict (eq $matching_queue "") }}
{{- fail (printf "No queue found with prefix '%s' in queue_names list" $prefix) }}
{{- end }}
{{- if eq $matching_queue "" }}
{{- $matching_queue = (index $queue_names 0) }}
{{- end }}
{{- $matching_queue }}
{{- end }} 