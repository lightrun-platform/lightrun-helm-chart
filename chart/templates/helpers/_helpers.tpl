{{/*
Common SecurityContext injected to all containers
runAsUser will be added to each container separately, due to "hardcoded" values
*/}}
{{- define "baseSecurityContext" -}}
{{ $SecurityContext := .Values.general.base_container_securityContext  }}
{{- if .Values.general.openshift -}}
{{ $_ := unset $SecurityContext "runAsUser" }}
{{- end -}}
{{ $SecurityContext | toYaml -}}
{{- end -}}




{{/*
################
### Backend  ###
################
*/}}

{{- define "lightrun-be.name" -}}
{{ .Release.Name }}-backend
{{- end -}}

{{/*
Create the name of the lightrun backend service account to use
*/}}
{{- define "lightrun-be.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "lightrun-be.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Container SecurityContext of lightrun backend
*/}}
{{- define "lightrun-be.containerSecurityContext" -}}
{{- $readOnlyRootFilesystem := dict "readOnlyRootFilesystem" (.Values.general.readOnlyRootFilesystem ) -}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext $readOnlyRootFilesystem -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.backend.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite $localSecurityContext (.Values.deployments.backend.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.backend.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}


{{/*
################
### Frontend ###
################
*/}}

{{- define "lightrun-fe.name" -}}
{{ .Release.Name }}-frontend
{{- end -}}

{{/*
Create the name of the lightrun frontend service account to use
*/}}
{{- define "lightrun-fe.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "lightrun-fe.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Container SecurityContext of lightrun frontend
*/}}
{{- define "lightrun-fe.containerSecurityContext" -}}
{{/*Merge runAsUser to default SecurityContext*/}}
{{- $readOnlyRootFilesystem := dict "readOnlyRootFilesystem" (.Values.general.readOnlyRootFilesystem) -}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext $readOnlyRootFilesystem -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.frontend.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite $localSecurityContext (.Values.deployments.frontend.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.frontend.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
################
### Keycloak ###
################
*/}}

{{- define "lightrun-keycloak.name" -}}
{{ .Release.Name }}-keycloak
{{- end -}}

{{/*
Create the name of the lightrun keycloak service account to use
*/}}
{{- define "lightrun-keycloak.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "lightrun-keycloak.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Container SecurityContext of lightrun keycloak
*/}}
{{- define "lightrun-keycloak.containerSecurityContext" -}}
{{/*Define a local variable baseSecurityContext with the minimum required securityContext on the container level*/}}
{{- $readOnlyRootFilesystem := dict "readOnlyRootFilesystem" (.Values.general.readOnlyRootFilesystem) -}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext $readOnlyRootFilesystem -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.keycloak.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite $localSecurityContext (.Values.deployments.keycloak.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.keycloak.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
helper that return the semver of `deplyoments.keycloak.image.tag`
In case of invalid semver it return 1.38.0
We then use the version to set Keycloak properties accordingly in file - templates/keycloak-deployment.yaml
We need this helper as Keycloak in version 25 onwards introduced hostname:v2 and we want to keep backwards compatability
More info here - https://www.keycloak.org/docs/25.0.2/upgrading/#migrating-to-25-0-0
Currently, here is what we do in file templates/keycloak-deployment.yaml:
            {{- $version := include "lightrun-keycloak.getParsedVersion" .Values.deployments.keycloak.image.tag -}}
            {{- if semverCompare ">=1.38.0" $version }}
            - name: KC_HOSTNAME
              value: 'https://{{ .Values.general.lightrun_endpoint }}/auth'
            {{- else }}
            - name: KC_HOSTNAME_URL
              value: 'https://{{ .Values.general.lightrun_endpoint }}/auth'
            {{- end }}
*/}}

{{- define "lightrun-keycloak.getSemanticVersion" -}}
  {{- $defaultVersion := "1.38.0" -}}
  {{- $inputVersion := . | default $defaultVersion | toString -}}
  {{- if regexMatch "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)" $inputVersion -}}
    {{- $parsedVersion := semver $inputVersion -}}
    {{- $major := $parsedVersion.Major -}}
    {{- $minor := $parsedVersion.Minor -}}
    {{- $patch := $parsedVersion.Patch -}}
    {{- $concatenatedVersion := printf "%d.%d.%d" $major $minor $patch -}}
    {{- $concatenatedVersion -}}
  {{- else -}}
    {{- $defaultVersion -}}
  {{- end -}}
{{- end -}}
{{/* END lightrun-keycloak.getSemanticVersion */}}

{{/*
################
####  Redis ####
################
*/}}


{{- define "lightrun-redis.name" -}}
{{ .Release.Name }}-redis
{{- end -}}

{{- define "lightrun-redis.endpoint" -}}
{{- if not .Values.deployments.redis.external.enabled -}}
{{ $.Release.Name }}-redis
{{- else -}}
{{ .Values.deployments.redis.external.endpoint }}
{{- end -}}
{{- end -}}

{{- define "lightrun-redis.protocol" -}}
{{- if or .Values.general.internal_tls.enabled .Values.deployments.redis.encryption.enabled -}}
rediss
{{- else -}}
redis
{{- end -}}
{{- end -}}

{{/*
Create the name of the lightrun redis service account to use
*/}}
{{- define "lightrun-redis.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "lightrun-redis.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Container SecurityContext of lightrun redis
*/}}
{{- define "lightrun-redis.containerSecurityContext" -}}
{{/*Define a local variable baseSecurityContext with the minimum required securityContext on the container level*/}}
{{- $readOnlyRootFilesystem := dict "readOnlyRootFilesystem" (.Values.general.readOnlyRootFilesystem) -}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext $readOnlyRootFilesystem -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.redis.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite  $localSecurityContext (.Values.deployments.redis.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.redis.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Define type of probes for redis, depends on the tls flag and type
*/}}
{{- define "lightrun-redis.probe" -}}
{{- if .Values.general.internal_tls.enabled  -}}
    {{- if and .Values.general.internal_tls.certificates.existing_ca_secret_name ( eq .Values.general.internal_tls.certificates.source "existing_certificates" ) }}
    {{/* TODO: validate that existing_ca not used with generate_sefl_signed */}}
exec:
  command:
  - redis-cli
  - -p
  - "{{ .Values.deployments.redis.port }}"
  - --tls
  - --cacert
  - /tmp/ca-cert/ca.crt
  - ping
    {{- else -}}  
    {{/* If self signed, no way to use redis-cli without CA cert, hence using tcp */}}
tcpSocket:
  port: {{ .Values.deployments.redis.port }}
    {{- end -}}
{{- else -}}
exec:
  command:
  - redis-cli
  - -p
  - "{{ .Values.deployments.redis.port }}"
  - ping
{{- end -}}
{{- end -}}



{{/*
################
#### Mysql #####
################
*/}}

{{- define "mysql.name" -}}
{{ .Release.Name }}-mysql
{{- end -}}

{{- define "mysql.pvc.name" -}}
    {{- if .Values.general.statefulset.pvc_name -}}
    {{ .Values.general.statefulset.pvc_name }}
    {{- else -}}
    mysql
    {{- end -}}
{{- end -}}

{{- define "mysql.db_endpoint" -}}
    {{- if .Values.general.db_local -}}
    {{ .Release.Name }}-mysql
    {{- else -}}
    {{ .Values.general.db_endpoint }}
    {{- end -}}
{{- end -}}

{{/*
Create the name of the mysql service account to use
*/}}
{{- define "mysql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "mysql.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Container SecurityContext of lightrun mysql
*/}}
{{- define "mysql.containerSecurityContext" -}}
{{/*Define a local variable baseSecurityContext with the minimum required securityContext on the container level*/}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext | default dict -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.mysql.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite $localSecurityContext (.Values.deployments.mysql.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.mysql.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Pod SecurityContext of lightrun mysql
*/}}
{{- define "mysql.podBaseSecurityContext" }}
{{ $podSecurityContext := .Values.deployments.mysql.podSecurityContext | default dict }}
{{- if .Values.general.openshift -}}
{{ $_ := unset $podSecurityContext "fsGroup" }}
{{- end -}}
{{ $podSecurityContext | toYaml -}}
{{- end -}}

{{/*
################
### RabbitMQ ###
################
*/}}

{{- define "lightrun-mq.name" -}}
{{ .Release.Name }}-mq
{{- end -}}

{{- define "lightrun-mq.storage.name" -}}
    {{- if and .Values.general.mq.pvc_name (ne (.Values.general.mq.storage | toString) "0") -}}
    {{ .Values.general.mq.pvc_name }}
    {{- else -}}
    {{ include "lightrun-mq.name" . }}-data
    {{- end -}}
{{- end -}}

{{- define "lightrun-mq.endpoint" -}}
    {{- if .Values.general.mq.local -}}
    {{ include "lightrun-mq.name" . }}
    {{- else -}}
    {{ .Values.general.mq.mq_endpoint }}
    {{- end -}}
{{- end -}}


{{- define "lightrun-mq.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "lightrun-mq.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Container SecurityContext of lightrun rabbitmq
*/}}
{{- define "rabbitmq.containerSecurityContext" -}}
{{/*Define a local variable baseSecurityContext with the minimum required securityContext on the container level*/}}
{{- $readOnlyRootFilesystem := dict "readOnlyRootFilesystem" (.Values.general.readOnlyRootFilesystem) -}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext $readOnlyRootFilesystem -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.rabbitmq.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite $localSecurityContext (.Values.deployments.rabbitmq.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.rabbitmq.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Pod SecurityContext of lightrun rabbitmq
*/}}
{{- define "rabbitmq.podBaseSecurityContext" }}
{{ $podSecurityContext := .Values.deployments.rabbitmq.podSecurityContext | default dict }}
{{- if .Values.general.openshift -}}
{{ $_ := unset $podSecurityContext "fsGroup" }}
{{- end -}}
{{ $podSecurityContext | toYaml -}}
{{- end -}}

{{/*
Return the number of bytes given a value
following a base 2 or base 10 number system.
Usage:
{{ include "rabbitmq.toBytes" .Values.path.to.the.Value }}
*/}}
{{- define "lightrun-mq.toBytes" -}}
{{- $value := int (regexReplaceAll "([0-9]+).*" . "${1}") }}
{{- $unit := regexReplaceAll "[0-9]+(.*)" . "${1}" }}
{{- if eq $unit "Ki" }}
    {{- mul $value 1024 }}
{{- else if eq $unit "Mi" }}
    {{- mul $value 1024 1024 }}
{{- else if eq $unit "Gi" }}
    {{- mul $value 1024 1024 1024 }}
{{- else if eq $unit "Ti" }}
    {{- mul $value 1024 1024 1024 1024 }}
{{- else if eq $unit "Pi" }}
    {{- mul $value 1024 1024 1024 1024 1024 }}
{{- else if eq $unit "Ei" }}
    {{- mul $value 1024 1024 1024 1024 1024 1024 }}
{{- else if eq $unit "K" }}
    {{- mul $value 1000 }}
{{- else if eq $unit "M" }}
    {{- mul $value 1000 1000 }}
{{- else if eq $unit "G" }}
    {{- mul $value 1000 1000 1000 }}
{{- else if eq $unit "T" }}
    {{- mul $value 1000 1000 1000 1000 }}
{{- else if eq $unit "P" }}
    {{- mul $value 1000 1000 1000 1000 1000 }}
{{- else if eq $unit "E" }}
    {{- mul $value 1000 1000 1000 1000 1000 1000 }}
{{- end }}
{{- end -}}

{{/*
################
### Secrets ####
################
*/}}

{{- define "secrets.deploy_secrets" -}}
{{- if (kindIs "bool" .Values.general.deploy_secrets)  -}}
    {{- if .Values.general.deploy_secrets -}}
        true
    {{- end -}} 
{{- else -}}
    {{- if .Values.general.deploy_secrets.enabled -}}
        true
    {{- end -}}
{{- end -}}
{{- end -}}


{{- define "secrets.certificate.name" -}}
{{- if .Values.certificate.existing_cert -}}
{{ .Values.certificate.existing_cert }}
{{- else -}}
{{ .Release.Name }}-certificate
{{- end -}}
{{- end -}}

{{- define "secrets.keycloak.name" -}}
{{- if (kindIs "bool" .Values.general.deploy_secrets)  -}}
{{ .Release.Name }}-keycloak
{{- else -}}
    {{- if .Values.general.deploy_secrets.enabled -}}
{{ .Release.Name }}-keycloak
    {{- else -}}
        {{- if .Values.general.deploy_secrets.existing_secrets.keycloak -}}
{{ .Values.general.deploy_secrets.existing_secrets.keycloak }}
        {{- else -}}
{{ .Release.Name }}-keycloak
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "secrets.backend.name" -}}
{{- if (kindIs "bool" .Values.general.deploy_secrets)  -}}
{{ .Release.Name }}-backend
{{- else -}}
    {{- if .Values.general.deploy_secrets.enabled -}}
{{ .Release.Name }}-backend
    {{- else -}}
        {{- if .Values.general.deploy_secrets.existing_secrets.backend -}}
{{ .Values.general.deploy_secrets.existing_secrets.backend }}
        {{- else -}}
{{ .Release.Name }}-backend
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}


{{- define "secrets.dockerhub.name" -}}
{{- if contains "lightrun" .Release.Name  -}}
{{ .Release.Name }}-dockerhub
{{- else -}}
{{ .Release.Name }}-lightrun-dockerhub
{{- end -}}
{{- end -}}



{{/*
################
#### Nginx  ####
################
*/}}

{{- define "nginx.name" -}}
{{ .Release.Name }}-nginx
{{- end -}}

{{/*
Create the name of the standalone nginx service account to use
*/}}
{{- define "nginx.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "nginx.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "nginx.conf-cm.name" -}}
{{ .Release.Name }}-nginx-conf
{{- end -}}


{{- define "nginx.containerSecurityContext" -}}
{{/*Merge runAsUser to default SecurityContext*/}}
{{- $readOnlyRootFilesystem := dict "readOnlyRootFilesystem" (.Values.general.readOnlyRootFilesystem) -}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext $readOnlyRootFilesystem -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.standalone_nginx.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite $localSecurityContext (.Values.deployments.standalone_nginx.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.standalone_nginx.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}



{{/*
#####################
### JVM Heap size ###
#####################
*/}}

{{- define "calculate-heap-size" -}}
{{ $heap:= "" }}
    {{- if contains "Gi" .resources.memory -}}
        {{- $heap = div (.resources.memory | replace "Gi" "" | int | mul 1024 | mul 75 ) 100  -}}
    {{- else if contains "Mi" .resources.memory -}}
        {{- $heap = div (.resources.memory | replace "Mi" "" | int | mul 75) 100  -}}
    {{- end -}}
{{- printf "-Xmx%vm -Xms%vm" $heap $heap -}}
{{- end -}}

{{- define "list-of-maps-contains" }}
    {{- $arg1 := index . 0 }}
    {{- $arg2 := index . 1 }}
    {{- range $arg1 }}
        {{- if eq .name $arg2 }}
            true
        {{- end }}
    {{- end }}
{{- end }}


{{/*
################
### Ingress ####
################
*/}}

{{- define "ingress.keycloak.name" -}}
{{ .Release.Name }}-keycloak-admin
{{- end -}}

{{- define "ingress.agents.name" -}}
{{ .Release.Name }}-agents
{{- end -}}

{{- define "ingress.clients.name" -}}
{{ .Release.Name }}-clients
{{- end -}}

{{- define "ingress.metrics.name" -}}
{{ .Release.Name }}-metrics
{{- end -}}

{{- define "lightrun-ingress.name" -}}
{{ .Release.Name }}-ingress
{{- end -}}




{{/*
###################
## Data streamer ##
###################
*/}}


{{- define "data_streamer.name" -}}
{{ .Release.Name }}-data-streamer
{{- end -}}



{{/*
Create the name of the lightrun data_streamer service account to use
*/}}
{{- define "data_streamer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "data_streamer.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Container SecurityContext of lightrun data_streamer
*/}}
{{- define "data_streamer.containerSecurityContext" -}}
{{/*Define a local variable baseSecurityContext with the minimum required securityContext on the container level*/}}
{{- $readOnlyRootFilesystem := dict "readOnlyRootFilesystem" (.Values.general.readOnlyRootFilesystem) -}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext $readOnlyRootFilesystem -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.data_streamer.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite  $localSecurityContext (.Values.deployments.data_streamer.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.data_streamer.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}


