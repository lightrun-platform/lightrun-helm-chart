{{/*
########################################
### Shared Backend/Crons             ###
########################################
*/}}

{{/*
Shared environment variables for backend and crons services
*/}}
{{- define "lightrun-backend-crons.environmentVariables" -}}
{{- if and .Values.general.system_config.content .Values.general.system_config.signature }}
- name: LIGHTRUN_SYSTEM_CONFIG_JSON_FILE_PATH
  value: "/opt/lightrun/system_config.json"
- name: LIGHTRUN_SYSTEM_CONFIG_JSON_SIGNATURE
  value: {{ .Values.general.system_config.signature }}
{{- end }}
- name: SERVER_SECURITY_ENCRYPTION-KEYS-PATH
  value: file:/encryption-keys
- name: LIGHTRUN_HOSTNAME
  value: {{ .Values.general.name }}
- name: POD_NAME
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: metadata.name
- name: INFO_DEPLOYMENT
{{ if eq .Values.general.deployment_type "saas" }}
  value: "SaaS"
{{ else if eq .Values.general.deployment_type "single-tenant" }}
  value: "single-tenant"
{{ else }}
  value: "on-prem"
{{ end }}
- name: SPRING_DATASOURCE_URL
  {{- if eq .Values.deployments.backend.dbConnector  "mysql" }}
  value: "jdbc:p6spy:mysql://{{ include "mysql.db_endpoint" . }}:3306/{{ .Values.general.db_database }}?useUnicode=true&characterEncoding=utf8&allowPublicKeyRetrieval=true&trustServerCertificate=true&useSSL={{ .Values.general.db_require_secure_transport }}"
  {{- else if eq .Values.deployments.backend.dbConnector  "mariadb" }}
  value: "jdbc:mariadb://{{ include "mysql.db_endpoint" . }}:3306/{{ .Values.general.db_database }}?allowPublicKeyRetrieval=true&trustServerCertificate=true&useSSL={{ .Values.general.db_require_secure_transport }}&rewriteBatchedStatements=true"
  {{- end }}
- name: SPRING_CACHE_JCACHE_CONFIG
  value: "file:///jcache-config/redisson-jcache-{{ .Values.deployments.redis.architecture }}.yaml"
- name: SPRING_FLYWAY_URL
  {{- if eq .Values.deployments.backend.dbConnector "mysql" }}
  value: "jdbc:mysql://{{ include "mysql.db_endpoint" . }}:3306/{{ .Values.general.db_database }}?useUnicode=true&characterEncoding=utf8&allowPublicKeyRetrieval=true&trustServerCertificate=true&useSSL={{ .Values.general.db_require_secure_transport }}"
  {{- else if eq .Values.deployments.backend.dbConnector "mariadb" }}
  value: "jdbc:mariadb://{{ include "mysql.db_endpoint" . }}:3306/{{ .Values.general.db_database }}?allowPublicKeyRetrieval=true&trustServerCertificate=true&useSSL={{ .Values.general.db_require_secure_transport }}"
  {{- end }}
- name: SPRING_SECURITY_OAUTH2_CLIENT_PROVIDER_KEYCLOAK_ISSUER-URI
  value: "https://{{ .Values.general.lightrun_endpoint }}/auth/realms/lightrun"
- name: SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER-URI
  value: "https://{{ .Values.general.lightrun_endpoint }}/auth/realms/lightrun"
- name: SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK-SET-URI
  value: "{{ include "http.scheme" . }}://{{ include "lightrun-keycloak.name" . }}:8080/auth/realms/lightrun/protocol/openid-connect/certs"
- name: SPRING_SECURITY_KEYCLOAK_URL
  value: "{{ include "http.scheme" . }}://{{ include "lightrun-keycloak.name" . }}:8080/auth"
{{ if or .Values.general.internal_tls.enabled .Values.deployments.redis.encryption.enabled }}
- name: SPRING_REDIS_SSL
  value: "true"
- name: REDIS_PROTOCOL_NAME
  value: "rediss"
{{ end }}
{{ if .Values.general.internal_tls.enabled }}
- name: SERVER_SSL_ENABLED
  value: "true"
{{ if .Values.general.mq.enabled }}
- name: SPRING_RABBITMQ_SSL_ENABLED
  value: "true"
{{ end }}
- name: TLS_SKIPCLIENTCERTIFICATEVERIFICATION
{{ if .Values.general.internal_tls.certificates.verification  }}
  value: "false"
{{ else }}
  value: "true"
{{ if .Values.general.mq.enabled }}
- name: SPRING_RABBITMQ_SSL_VALIDATE-SERVER-CERTIFICATE
  value: "false"
{{ end }}
{{ end }}
{{ end }}
{{- if not .Values.deployments.redis.auth.enabled }}
- name: SPRING_REDIS_PASSWORD #to disable password auth even if secret contains password, but auth_enabled is false
  value: null
{{- end }}
- name: SPRING_SECURITY_KEYCLOAK_PORT
  value: "8080"
- name: SPRING_SECURITY_KEYCLOAK_EXTRA-REDIRECT-URLS
  value: "https://{{ .Values.general.lightrun_endpoint }}/*"
- name: SPRING_SECURITY_KEYCLOAK_EXTERNAL-URL
  value: "https://{{ .Values.general.lightrun_endpoint }}/auth"
- name: JHIPSTER_SLEEP
  value: "5000" # gives time for other services to boot before the application
- name: INTEGRATIONS_ENABLE
  value: "true"
- name: INTEGRATIONS_DATADOG_ENABLE
  value: "false"
- name: SERVER_EXTERNAL_HOST
  value: "{{ .Values.general.lightrun_endpoint }}"
- name: SERVER_EXTERNAL_PORT
  value: "443"
- name: SPRING_REDIS_HOST
  value: {{ include "lightrun-redis.endpoint" . }}
- name: SPRING_REDIS_PORT
  value: "{{ .Values.deployments.redis.port }}"
- name: SERVER_DISPLAY_PORT
  value: "443"
- name: SPRING_FLYWAY_SCHEMAS
  value: {{ .Values.general.db_database }}
- name: KEYSTORE_PATH
  value: "file:/p12/lightrun.p12"
- name: SYSTEM_DEFAULT_USER_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "secrets.backend.name" . }}
      key: SPRING_SECURITY_KEYCLOAK_CLI_PASSWORD
- name: ARTIFACTS_ENABLE_S3_FEATURE #TODO: deprecated in favor of ARTIFACTS_ENABLE in 2.1.7
  value: {{ .Values.deployments.backend.artifacts.enable | quote }}
- name: ARTIFACTS_ENABLE
  value: {{ .Values.deployments.backend.artifacts.enable | quote }}
- name: ARTIFACTS_S3_URL   #TODO: deprecated in favor of ARTIFACTS_REPOSITORY_URL in 2.1.7
  value: "{{ .Values.deployments.backend.artifacts.s3_url }}"
- name: ARTIFACTS_REPOSITORY_URL
  value: "{{ .Values.deployments.backend.artifacts.repository_url }}"
- name: ARTIFACTS_SUPPORTED_VERSIONS_URL
  value: "{{ .Values.deployments.backend.artifacts.supported_versions_url }}"
- name: ARTIFACTS_DOWNLOAD_PRERELEASE #TODO: deprecated in favor of ARTIFACTS_VERSION_RESOLUTION_MODE in 2.1.7
  value: "{{ .Values.deployments.backend.artifacts.download_prerelease }}"
- name: ARTIFACTS_VERSION_RESOLUTION_MODE
  value: "{{ .Values.deployments.backend.artifacts.resolution_mode }}"
- name: LIGHTRUN_ARTIFACTS_URL
  value: "{{ include "http.scheme" . }}://{{ include "artifacts.name" . }}:8080"              
{{- if .Values.general.mq.enabled }}
- name: SPRING_RABBITMQ_HOST
  value: {{ include "lightrun-mq.endpoint" . }}
- name: SPRING_RABBITMQ_PORT
  value: {{ .Values.general.mq.port | quote }}
- name: TRACKING_MIXPANEL_QUEUE_NAME
  value: {{ include "lightrun-mq.getQueueNameByPrefix" (dict "prefix" "mixpanel-events" "Values" .Values) | quote }}
- name: KEYCLOAK_QUEUE_NAME
  value: {{ include "lightrun-mq.getQueueNameByPrefix" (dict "prefix" "keycloak-events" "Values" .Values) | quote }}
{{- end }}
- name: LOGGING_USE-JSON-FORMAT
  value: "{{ .Values.deployments.backend.useJsonLogFormat }}"
{{- if .Values.general.data_streamer.enabled }}
- name: INTEGRATIONS_SIEM_STREAMING-SERVICE_URL
  value: "{{ include "http.scheme" . }}://{{ include "data_streamer.name" . }}:8080/events/post"
{{- end }}
{{- end -}}

{{/*
Shared volumes for backend and crons services
*/}}
{{- define "lightrun-backend-crons.volumes" -}}
{{- if and .Values.general.system_config.content .Values.general.system_config.signature }}
- name: system-config
  configMap:
    name: {{ include "lightrun.fullname" . }}-system-config
{{- end }}
- name: encryption-keys
  secret: 
    secretName: {{ include "secrets.backend.name" . }}
    optional: true
    items: 
      # Only select items that start with encryption-key-
      {{- include "encryption.key.items" . | nindent 6 }}

{{- if and .Values.general.internal_tls.enabled .Values.general.internal_tls.certificates.existing_ca_secret_name  }}  
- name: ca-cert
  secret:
    secretName: {{ .Values.general.internal_tls.certificates.existing_ca_secret_name }}
{{- end }}
- name: jcache-config
  configMap:
    name: {{ include "lightrun-be.name" . }}-jcache-config
    items:
      - key: "redisson-jcache-single.yaml"
        path: "redisson-jcache-single.yaml"
      - key: "redisson-jcache-replicated.yaml"
        path: "redisson-jcache-replicated.yaml"
- name: certificates
  secret:
    secretName: {{ include "secrets.certificate.name" . }}
- name: p12
  emptyDir:
    sizeLimit: 50Mi

{{- if .Values.general.readOnlyRootFilesystem }}
- name: tmpfs
  emptyDir:
    sizeLimit: {{ .Values.general.readOnlyRootFilesystem_tmpfs_sizeLimit }}
{{- end }}
{{- end -}}

{{/*
Shared volume mounts for backend and crons services
*/}}
{{- define "lightrun-backend-crons.volumeMounts" -}}
{{- if and .Values.general.system_config.content .Values.general.system_config.signature }}
- name: system-config
  mountPath: "/opt/lightrun/system_config.json"
  subPath: "system_config.json"
  readOnly: true
{{- end }}
- name: encryption-keys
  mountPath: /encryption-keys
  readOnly: true
- name: jcache-config
  mountPath: "/jcache-config"
- name: certificates
  mountPath: /usr/src/lightrun/helm/tls
- name: p12
  mountPath: /p12
- name: dumps
  mountPath: /dumps
{{- if .Values.general.readOnlyRootFilesystem }}
- name: tmpfs
  mountPath: /tmp
{{- end }}
{{- end -}}

{{/*
Shared init containers for backend and crons services
*/}}
{{- define "lightrun-backend-crons.initContainers" -}}


- name: wait-for-keycloak
  image: "{{ .Values.deployments.backend.initContainers.wait_for_keycloak.image.repository }}:{{ .Values.deployments.backend.initContainers.wait_for_keycloak.image.tag }}"
  imagePullPolicy: {{ .Values.deployments.backend.initContainers.wait_for_keycloak.image.pullPolicy }}
  securityContext: {{ include "lightrun-be.containerSecurityContext" . | indent 4 }}
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
    - name: URL
      value: {{ include "http.scheme" . }}://{{ include "lightrun-keycloak.name" . }}:9000/auth/health/started {{ if .Values.general.internal_tls.enabled }}--no-check-certificate{{ end }}

{{ if .Values.general.mq.enabled }}
{{- include "lightrun-mq.initContainer.wait-for-rabbitmq" (merge (dict "imageConfig" .Values.deployments.backend.initContainers.wait_for_rabbitmq "securityContext" "lightrun-be.containerSecurityContext") .) }}
{{- end }}
- name: p12-creator
  image: "{{ .Values.deployments.backend.initContainers.p12_creator.image.repository }}:{{ .Values.deployments.backend.initContainers.p12_creator.image.tag }}"
  imagePullPolicy: {{ .Values.deployments.backend.initContainers.p12_creator.image.pullPolicy }}
  securityContext: {{ include "lightrun-be.containerSecurityContext" . | indent 4 }}
  resources:
    limits:
      memory: "200Mi"
      cpu: "200m"
    requests:
      memory: "200Mi"
      cpu: "200m"
  env:
  - name: KEYSTORE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ include "secrets.backend.name" . }}
        key: KEYSTORE_PASSWORD
  volumeMounts:
  - name: certificates
    mountPath: /tls
  - name: p12
    mountPath: /p12
  command: ['sh', '-c', 'cp /tls/tls.crt /p12/crt.pem && cp /tls/tls.key /p12/key.pem && openssl pkcs12 -export -out /p12/lightrun.p12 -inkey /p12/key.pem -in /p12/crt.pem -passin pass:$KEYSTORE_PASSWORD -passout pass:$KEYSTORE_PASSWORD']

{{- if and .Values.general.internal_tls.enabled .Values.general.internal_tls.certificates.existing_ca_secret_name }}  
- name: root-ca-creator
  image: "{{ .Values.deployments.backend.image.repository }}:{{ .Values.deployments.backend.image.tag }}"
  securityContext: {{ include "lightrun-be.containerSecurityContext" . | indent 4 }}
  resources:
    limits:
      memory: "100Mi"
      cpu: "100m"
    requests:
      memory: "100Mi"
      cpu: "100m"
  env:
  - name: KEYSTORE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ include "secrets.backend.name" . }}
        key: KEYSTORE_PASSWORD
  volumeMounts:
  - name: ca-cert
    mountPath: /tmp/ca-certificates/
  - name: p12
    mountPath: /p12
  command: ['sh', '-c', 'keytool -import -trustcacerts -alias internalCa -keystore /p12/internalca -file  /tmp/ca-certificates/ca.crt -noprompt -storepass $KEYSTORE_PASSWORD && keytool -importkeystore -srckeystore /usr/lib/jvm/default-jvm/jre/lib/security/cacerts -destkeystore /p12/internalca -srcstorepass changeit -deststorepass $KEYSTORE_PASSWORD']
{{- end }}
{{- end -}}