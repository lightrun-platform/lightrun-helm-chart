{{/*
Create a wait-for-rabbitmq init container
*/}}
{{- define "lightrun-mq.initContainer.wait-for-rabbitmq" -}}
{{- $imageConfig := .imageConfig -}}
{{- $securityContext := .securityContext -}}
- name: wait-for-rabbitmq
  image: "{{ $imageConfig.image.repository }}:{{ $imageConfig.image.tag }}"
  imagePullPolicy: {{ $imageConfig.image.pullPolicy }}
  securityContext: {{ include $securityContext . | indent 10 }}
  command:
    - sh
    - /scripts/wait-for-200.sh
  resources:
    limits:
      memory: "100Mi"
      cpu: "100m"
    requests:
      memory: "100Mi"
      cpu: "100m"
  env:
    - name: MY_POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
    - name: AUTH_USER
      valueFrom:
        secretKeyRef:
          name: {{ include "secrets.backend.name" . }}
          key: SPRING_RABBITMQ_USERNAME
    - name: AUTH_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ include "secrets.backend.name" . }}
          key: SPRING_RABBITMQ_PASSWORD
    - name: RABBITMQ_TCP_PORT
      value: "15672"
    - name: URL
      value: {{ include "http.scheme" . }}://{{ include "lightrun-mq.endpoint" . }}:$(RABBITMQ_TCP_PORT)/api/overview {{ if .Values.general.internal_tls.enabled }}--no-check-certificate{{ end }}
{{- end -}} 