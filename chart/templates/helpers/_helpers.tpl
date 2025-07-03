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
Create a default fully qualified app name. If used, it overrides the release name embedded across all chart k8s related objects.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "lightrun.fullname" -}}
{{- default .Release.Name .Values.general.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
################
### Backend  ###
################
*/}}

{{- define "lightrun-be.name" -}}
{{ include "lightrun.fullname" . }}-backend
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
{{ include "lightrun.fullname" . }}-frontend
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
{{ include "lightrun.fullname" . }}-keycloak
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
We then use the version to set Keycloak properties accordingly in file - templates/keycloak-statefulset.yaml
We need this helper as Keycloak in version 25 onwards introduced hostname:v2 and we want to keep backwards compatability
More info here - https://www.keycloak.org/docs/25.0.2/upgrading/#migrating-to-25-0-0
Currently, here is what we do in file templates/keycloak-statefulset.yaml:
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
{{ include "lightrun.fullname" . }}-redis
{{- end -}}

{{- define "lightrun-redis.endpoint" -}}
{{- if not .Values.deployments.redis.external.enabled -}}
{{ include "lightrun.fullname" . }}-redis
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
{{ include "lightrun.fullname" . }}-mysql
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
    {{ include "lightrun.fullname" . }}-mysql
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
{{ include "lightrun.fullname" . }}-mq
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
{{ include "lightrun.fullname" . }}-certificate
{{- end -}}
{{- end -}}

{{- define "secrets.keycloak.name" -}}
{{- if (kindIs "bool" .Values.general.deploy_secrets)  -}}
{{ include "lightrun.fullname" . }}-keycloak
{{- else -}}
    {{- if .Values.general.deploy_secrets.enabled -}}
{{ include "lightrun.fullname" . }}-keycloak
    {{- else -}}
        {{- if .Values.general.deploy_secrets.existing_secrets.keycloak -}}
{{ .Values.general.deploy_secrets.existing_secrets.keycloak }}
        {{- else -}}
{{ include "lightrun.fullname" . }}-keycloak
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "secrets.backend.name" -}}
{{- if (kindIs "bool" .Values.general.deploy_secrets)  -}}
{{ include "lightrun.fullname" . }}-backend
{{- else -}}
    {{- if .Values.general.deploy_secrets.enabled -}}
{{ include "lightrun.fullname" . }}-backend
    {{- else -}}
        {{- if .Values.general.deploy_secrets.existing_secrets.backend -}}
{{ .Values.general.deploy_secrets.existing_secrets.backend }}
        {{- else -}}
{{ include "lightrun.fullname" . }}-backend
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "secrets.dockerhub.name" -}}
{{- if contains "lightrun" (include "lightrun.fullname" .)  -}}
{{ include "lightrun.fullname" . }}-dockerhub
{{- else -}}
{{ include "lightrun.fullname" . }}-lightrun-dockerhub
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
###################
## Data streamer ##
###################
*/}}


{{- define "data_streamer.name" -}}
{{ include "lightrun.fullname" . }}-data-streamer
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

{{/*
###################
## Artifacts ##
###################
*/}}


{{- define "artifacts.name" -}}
{{ include "lightrun.fullname" . }}-artifacts
{{- end -}}



{{/*
Create the name of the lightrun artifacts service account to use
*/}}
{{- define "artifacts.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "artifacts.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Container SecurityContext of lightrun artifacts
*/}}
{{- define "artifacts.containerSecurityContext" -}}
{{/*Define a local variable baseSecurityContext with the minimum required securityContext on the container level*/}}
{{- $readOnlyRootFilesystem := dict "readOnlyRootFilesystem" (.Values.general.readOnlyRootFilesystem) -}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext $readOnlyRootFilesystem -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.artifacts.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite  $localSecurityContext (.Values.deployments.artifacts.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.artifacts.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Get queue name by prefix from the queue_names list.

Parameters:
- prefix: The prefix to match against queue names
- Values: The chart values context

Returns:
- The first queue name that matches the prefix
- Fails if no matching queue is found
*/}}
{{- define "lightrun-mq.getQueueNameByPrefix" -}}
{{- $queue_names := .Values.general.mq.queue_names | default (list .Values.general.mq.queue_name) }}
{{- if not $queue_names }}
{{- fail "No queue names defined in general.mq.queue_names or general.mq.queue_name" }}
{{- end }}
{{- $prefix := .prefix | default "" | lower }}
{{- $matching_queue := "" }}
{{- range $queue_names }}
{{- if and . (hasPrefix $prefix (. | lower)) }}
{{- $matching_queue = . }}
{{- break }}
{{- end }}
{{- end }}
{{- if eq $matching_queue "" }}
{{- fail (printf "No queue found with prefix '%s' in queue_names list" $prefix) }}
{{- end }}
{{- $matching_queue }}
{{- end }}

{{/*
Get encryption key for Lightrun deployment. Handles existing keys, random generation, or user-provided values.
*/}}
{{- define "secrets.encryption-key" -}}
    {{- if .Values.general.deploy_secrets.enabled }}
        {{- if (not .Values.secrets.keysEncryption.userEncryptionKey) }}
            {{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "secrets.backend.name" .)) }}
            {{/* Case 1: take existing generated key from secret */}}
            {{- if and $secretObj (hasKey $secretObj.data ( include "secrets.encryption-key-name" . ) ) }}
                {{- index $secretObj.data ( include "secrets.encryption-key-name" . ) | b64dec }}
            {{/* Case 2: generate random encryption key */}}
            {{- else }}
                {{- randBytes 32 }}
            {{- end }}
        {{/* Case 3: take user provided encryption key from values */}}
        {{- else }}
            {{- .Values.secrets.keysEncryption.userEncryptionKey }}
        {{- end }}
    {{- end }}
{{- end }}

{{- define "secrets.encryption-key-name" -}}
    {{- $rotateKey := .Values.secrets.keysEncryption.rotateKey }}
    {{- $defaultKey := "encryption-key-0" }}
    {{- $keyPrefix := "encryption-key-" }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "secrets.backend.name" .)) }}

    {{- $maxIndex := -1 }}
    {{- if $secret }}
        {{- range $k, $ := $secret.data }}
            {{- if hasPrefix $keyPrefix $k }}
                {{- $suffix := trimPrefix $keyPrefix $k }}
                {{- $num := int $suffix }}
                {{- if gt $num $maxIndex }}
                    {{- $maxIndex = $num }}
                {{- end }}
            {{- end }}
        {{- end }}
    {{- end }}

    {{- if eq $maxIndex -1 }}
        {{- $defaultKey }}
    {{- else if $rotateKey }}
        {{- printf "encryption-key-%d" (add1 $maxIndex) }}
    {{- else }}
        {{- printf "encryption-key-%d" $maxIndex }}
    {{- end }}
{{- end }}

{{/* Helper function to render encryption key items */}}
{{- define "encryption.key.items" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "secrets.backend.name" .)) -}}
{{- $hasEncryptionKeys := false -}}
{{- if $secret -}}
{{ range $key, $value := $secret.data }}
{{ if hasPrefix "encryption-key-" $key }}
{{- $hasEncryptionKeys = true }}
- key: {{ $key }}
  path: {{ $key }}
{{- end }}
{{- end }}
{{- end }}
{{ if not $hasEncryptionKeys }}
- key: encryption-key-0
  path: encryption-key-0
{{- end }}
{{ if .Values.secrets.keysEncryption.rotateKey }}
- key: {{ include "secrets.encryption-key-name" . }}
  path: {{ include "secrets.encryption-key-name" . }}
{{- end }}
{{- end }}

{{/*
########################################
### Shared Backend/Background Tasks ###
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

{{/*
####################
### Crons Service ###
####################
*/}}

{{- define "lightrun-crons.name" -}}
{{ include "lightrun.fullname" . }}-crons
{{- end -}}

{{/*
Create the name of the lightrun crons service account to use
*/}}
{{- define "lightrun-crons.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "lightrun-crons.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Container SecurityContext of lightrun crons
*/}}
{{- define "lightrun-crons.containerSecurityContext" -}}
{{- $readOnlyRootFilesystem := dict "readOnlyRootFilesystem" (.Values.general.readOnlyRootFilesystem ) -}}
{{- $baseSecurityContext := include "baseSecurityContext" . | fromYaml -}}
{{- $localSecurityContext := mustMerge $baseSecurityContext $readOnlyRootFilesystem -}}
{{/*If user provided values for containerSecurityContext, merge them with the baseSecurityContext*/}}
{{/*Values passed by user will override defaults*/}}
{{- if .Values.deployments.crons.containerSecurityContext -}}
{{- $mergedSecurityContext := mergeOverwrite $localSecurityContext (.Values.deployments.crons.containerSecurityContext | default dict) -}}
{{- $mergedSecurityContext | toYaml -}}
{{- else if kindIs "invalid" .Values.deployments.crons.containerSecurityContext -}}
{{ default dict | toYaml -}}
{{- else -}}
{{/*use default values from baseSecurityContext*/}}
{{- $localSecurityContext | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Cron-specific asyncProfiler helpers
*/}}
{{- define "lightrun-crons.volumes.asyncProfiler" -}}
{{- if .Values.deployments.crons.asyncProfiler.enabled -}}  
{{ include "asyncProfiler.volumes" .Values.deployments.crons.asyncProfiler }}
{{- end -}}
{{- end -}}

{{- define "lightrun-crons.volumeMounts.asyncProfiler" -}}
{{- if .Values.deployments.crons.asyncProfiler.enabled }} 
{{- include "asyncProfiler.volumeMounts" . }}
{{- end -}}
{{- end -}}

{{- define "lightrun-crons.initContainer.download-async-profiler" -}}
{{- if .Values.deployments.crons.asyncProfiler.enabled -}}  
{{ include "asyncProfiler.initContainer.download-async-profiler" .Values.deployments.crons.asyncProfiler }}
  securityContext: {{- include "lightrun-crons.containerSecurityContext" . | indent 4 }}
{{- end -}}
{{- end -}}

{{- define "lightrun-crons.container.persist-async-profiler-output-files" -}}
{{- if and .Values.deployments.crons.asyncProfiler.enabled .Values.deployments.crons.asyncProfiler.persistence.enabled }}  
{{ include "asyncProfiler.container.persist-async-profiler-output-files" . }}
  securityContext: {{- include "lightrun-crons.containerSecurityContext" . | indent 4 }}
{{- end -}}
{{- end -}}

{{- define "lightrun-crons.java.argument.asyncProfiler" -}}
{{- if .Values.deployments.crons.asyncProfiler.enabled -}}  
"{{- include "asyncProfiler.java.agentpath" .Values.deployments.crons.asyncProfiler -}}",
{{- end -}}
{{- end -}}

{{/*
Merge extraEnvs from backend and crons with crons taking precedence for duplicate keys
*/}}
{{- define "lightrun-crons.mergedExtraEnvs" -}}
{{- $backendExtraEnvs := .Values.deployments.backend.extraEnvs | default list -}}
{{- $cronsExtraEnvs := .Values.deployments.crons.extraEnvs | default list -}}
{{- $mergedEnvs := list -}}

{{/* First, add all backend extraEnvs */}}
{{- range $backendExtraEnvs -}}
{{- $backendEnv := . -}}
{{- $isOverridden := false -}}
{{/* Check if this env var is overridden in crons */}}
{{- range $cronsExtraEnvs -}}
{{- if eq .name $backendEnv.name -}}
{{- $isOverridden = true -}}
{{- end -}}
{{- end -}}
{{/* Only add backend env if not overridden by crons */}}
{{- if not $isOverridden -}}
{{- $mergedEnvs = append $mergedEnvs $backendEnv -}}
{{- end -}}
{{- end -}}

{{/* Then, add all crons extraEnvs (these take precedence) */}}
{{- range $cronsExtraEnvs -}}
{{- $mergedEnvs = append $mergedEnvs . -}}
{{- end -}}

{{/* Output merged envs as YAML if any exist */}}
{{- if $mergedEnvs -}}
{{- toYaml $mergedEnvs -}}
{{- end -}}
{{- end -}}

{{/*
Check if merged extraEnvs contain _JAVA_OPTIONS
*/}}
{{- define "lightrun-crons.hasJavaOptions" -}}
{{- $backendExtraEnvs := .Values.deployments.backend.extraEnvs | default list -}}
{{- $cronsExtraEnvs := .Values.deployments.crons.extraEnvs | default list -}}
{{- $javaOptionsEnvs := list -}}

{{/* Check backend extraEnvs for _JAVA_OPTIONS */}}
{{- range $backendExtraEnvs -}}
{{- if eq .name "_JAVA_OPTIONS" -}}
{{- $isOverridden := false -}}
{{/* Check if this env var is overridden in crons */}}
{{- range $cronsExtraEnvs -}}
{{- if eq .name "_JAVA_OPTIONS" -}}
{{- $isOverridden = true -}}
{{- end -}}
{{- end -}}
{{/* Only consider it if not overridden by crons */}}
{{- if not $isOverridden -}}
{{- $javaOptionsEnvs = append $javaOptionsEnvs . -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Check crons extraEnvs for _JAVA_OPTIONS (these take precedence) */}}
{{- range $cronsExtraEnvs -}}
{{- if eq .name "_JAVA_OPTIONS" -}}
{{- $javaOptionsEnvs = append $javaOptionsEnvs . -}}
{{- end -}}
{{- end -}}

{{- if $javaOptionsEnvs -}}
true
{{- end -}}
{{- end -}}


