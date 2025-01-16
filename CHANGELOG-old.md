### 3.9.4
- RabbitMQ changes: added a post-start container to persist the RabbitMQ default user.

### 3.9.3
- change: always pull when tag is set to latest

### 3.9.2
- fix: wait for init rabbit endpoint

### 3.9.1
- RabbitMQ changes: 
- Exported out configuration of mixpanel events queue such as queue name, with the creation of queue and dlq based on definitions.json in rabbitmq's configmap.
- Supported new configuration for them with policies assigned based on regex that applies on the mixpanel-events queue with parameters like; `messages-ttl`, `max-size-bytes`, and `max-size`.
- Added support for changing log level in rabbitmq pod, default is INFO.

### 3.9.0
- Keycloak: Added KC_PROXY_HEADERS environment variable with fixed value xforwarded.

### *Attention*:
This change is introduced in Lightrun version 1.48.0 onwards, which alters the default Keycloak behavior. To ensure Keycloak functions properly, Lightrun now configures the KC_PROXY_HEADERS environment variable to be set to xforwarded in the Keycloak deployment.

When using Lightrun Router: No additional configuration is needed as the router will automatically set the required headers.

When not using Lightrun Router: The proxy sending traffic into the Lightrun cluster MUST ensure that the X-Forwarded-For headers are set.

### 3.8.7
- removed irrelevant comment in helpers.tpl file led to templating error

### 3.8.6
- fixed issue where pvc name for mysql sts is defined but not used in the mysql sts object

### 3.8.5
- add upstream status code and response time to the router access logs

### 3.8.4
- fix small async-profiler integration issues

### 3.8.3
- added support for changing log level in data streamer, default is INFO

### 3.8.2
- allow to specify `nightly` async-profiler version

### 3.8.1 
- add `request_id` header to the flow:
    - router will propagate header to it's upstream (or generate in case of missing) 
    - add header to router log
    - add  header to frontend log

### 3.8.0
- enable router by default in the values
> [!WARNING]  
> Breaking change in the chart defaults  
> Router is now enabled by default (with ingress object)  

Revert the change
```
In order to `revert the change` to previous defaults, set `general.router.enabled` to false in the values.yaml
```
Migrate to the router from previous defaults:
```
In order to migrate to the router from previous defaults (multiple ingress objects) -> move all the configuration specific to the ingress controller (`annotations`, `labels`, `ingressClass`) to general.router.ingress  
Note that by default all traffic to /auth/admin will be blocked. It can be changed in the general.router.acl configuration  

If you are migrating from non default ingress configuration, please, consult with Lightrun SE 
```

### 3.7.2
- integrate the async-profiler to backend & keycloak (disabled by default)

### 3.7.1
- bump redis revision due to CVEs
- bump data-streamer patch version

### 3.7.0
- change default values
    - Backend - Mem 13->7G 
    - Keycloak - CPU 2000m->1000m 
    - MySql - CPU 4000m->2000m, Mem 16G->8G 
    - Data Streamer - CPU 500m->100m, Mem 512M->128M

### 3.6.12
- remove support for TLS 1.1 from the router

### 3.6.11
- use keycloak health checks for startup, readiness and liveness probes

> [!WARNING]
> this change works with lightrun version >= `1.42.0` otherwise fallbacks to previous logic

### 3.6.10
- update default router version to `alpine-3.20.0-r1`

### 3.6.9
- allow to set KC_HOSTNAME for keycloak via extraEnvs

### 3.6.8
- upgrade data-streamer to 4.33.0

### 3.6.7
- error pages static resources are embedded to router instead of redirect to external storage
    > this change require router version >= alpine-3.20.0-r0
- update default router version to `alpine-3.20.0-r0`

### 3.6.6
- reduce default resources of `frontend`

### 3.6.5
- add memory to hpa resources for backend, frontend, router
- remove `replicas` field from the deployment spec when hpa is enabled

### 3.6.4
- fix configmap hash in router deployment

### 3.6.3
- gateway configmap replace /auth/ to /auth endpoint 

### 3.6.2
- template styling change
> replace all `toYaml | indent` to `nindent`

### 3.6.1
- increase startup probe timeout to 10 min for the cases of long DB migrations

### 3.6.0
> [!WARNING]
> Breaking change for the `gateway` feature
- rename `gateway` to `router` due to confusion with k8s gateway resource
- decouple ingress and service objects in the router enabled mode
- introduce `router.tls.enabled` flag that will control the SSL termination.

#### Migration of the gateway's values to router
```yaml
general:
    gateway:
        enabled: false
        exposed_by:
            ingress:
                enabled: true
                ingress_class_name: "nginx"
                annotations: {}
                labels: {}
                service:
                    type: ClusterIP
                    annotations: {}
                    labels: {}

            service:
                enabled: false
                type: "LoadBalancer" # NodePort or Headless
                annotations: {}
                labels: {}

            host_port:
                enabled: false
                ports:
                    http: 80
                    https: 443
deployments:
    gateway:
        ...
```
to 
```yaml
general:
    router:
        enabled: false
        tls:
            enabled: false

        ingress:
            enabled: true
            ingress_class_name: "nginx"
            annotations: {}
            labels: {}

        service:
            enabled: true
            ## Supported types: ClusterIP, LoadBalancer, NodePort, Headless
            type: "ClusterIP"
            annotations: {}
            labels: {}
            ports:
                http: 8080
                https: 8443

        host_port:
            enabled: false
            ports:
                http: 80
                https: 443
deployments:
    router:
        ...
```

### 3.5.19
- add keycloak helper that set KC_HOSTNAME if keycloak tag semver is grater or equal to 1.38 otherwise set KC_HOSTNAME_URL for backward compatibility. this change is to support keycloak version 25. in case of invalid semver tag, we take the newer Keycloak config, meaning we expect the version is >= 1.38 no matter what is the tag name  

### 3.5.18
- fix gateway redirect to keycloak

### 3.5.17
- fix gateway deployment health-checks when exposed by service 

### 3.5.16
- override nginx.conf in gateway
- add ability to change worker's configuration

### 3.5.15
- mysql default image from the official repo
- bump mysql to 8.0.38

### 3.5.14
When installing on `openshift` with `gateway` enabled
- remove `ingressClassName` from gateway ingress
- generate common config for frontend 
- add request timeout annotation to gateway ingress

### 3.5.13
- option to change underlying service type of ingress object when using `gateway exposed by ingress`
> It can be usefull when using AWS load balancer controller for provisioning ALB for ingress handling.  
> In this case service has to be `NodePort` or target type has to be `ip`

### 3.5.12
- fix `data_streamer` replicas value

### 3.5.11
- gateway fix error with too big request headers (keycloak auth cookies)

### 3.5.10
- add pod annotations and labels to all pods and services
    > [!WARNING]
    >  Deprecation note
    > `annotations: {}` field in the deployments is deprecated  
    > use `podAnnotations` instead
- add healthcheck to gateway

### 3.5.9
- tune gateway config

### 3.5.8
- update data streamer internal URI

### 3.5.7
- remove duplicate field from gateway log

### 3.5.6
- fix gateway indentations

### 3.5.5

- add data streamer URL env var to backend
- add pdb for gateway

### 3.5.4

- `internal_tls` support on gateway

### 3.5.3

- added podLabels 

### 3.5.2

- added gateway features:
    - ability to block ips
    - global rate limit
    - config snippets
    - hpa
- bump data-streamer version

### 3.5.1

- fix bug with rabbit pvc name

### 3.5.0

- health-check endpoint in frontend and compression
- add data-streamer component (pre-release version)
- optional json log format for frontend/keycloak/backend/data-streamer
- add option for pod disruption budget frontend/keycloak/backend/data-streamer
- fix `nodeSelector` of mysql and rabbit
- fix `readonlyFilesystem` for keycloak

### 3.4.0
- fix bug with mysql readiness probe when `db_require_secure_transport` enabled
- add encryption for traffic between the keycloak pods when in `cluster` mode and `internal_tls` is enabled
> cluster mode tls is only available when providing existing certificates to the chart
- default value for backend memory request/limit to 13G

### 3.3.9
- mark the gateway as experimental and all other exposure methods as not deprecated

### 3.3.8
- fix frontend-cm for openshift
- fix if conditions of frontend-cm and ingress of openshift
- fix securityContext for openshift

### 3.3.7
- add ability to change `persistentVolumeClaimRetentionPolicy` for mysql and rabbit statefulsets

### 3.3.6
- move redis back to alpine based image with newer redis version
> Removes critical CVEs

### 3.3.5
- move to hardened version of redis image.
> It has protection mode enabled, hence we need to disable it when running without authentication

### 3.3.4
- bump mysql image to 8.0.37

### 3.3.3
- change readMode to MASTER_SLAVE of replicated redis config

### 3.3.2
- fix config path of frontend due to the new image

### 3.3.1
- change default keycloak configuration `clusterMode` to `true`
- update xff headers of the gateway

### 3.3.0
- fix `nodeSelector` of the backend pod

### 3.2.1
- fix gateway ingress object annotations

### 3.2.0
- add an option to set custom gateway server snippets
```yaml
general:
    gateway:
        server_snippets: |
            location /teapot {
                return 418;
            }
```

### 3.1.1
- Bump redis base image to  `7.0.15-alpine3.19`

### 3.1.0
- add gateway (beta version)

```yaml
general:
    gateway:
        enabled: true
```

### 3.0.2
- add flag trustServerCertificate=true to jdbc for keycloak and backend

### 3.0.1
- add flag rewriteBatchedStatements=true to jdbc

### 3.0.0
> [!WARNING]  
> Breaking changes

- replace db connector from mysql to mariadb in backend and keycloak . requires lightrun version >= 1.30
```yaml
deployments:
  backend:
    dbConnector: "mariadb" # either mysql for versions < .1.30 or mariadb (default) for versions > 1.30
  keycloak:
    dbConnector: "mariadb" # either mysql for versions < .1.30 or mariadb (default) for versions > 1.30
```

### 2.18.0
- add ability to pass jcache config to backend
```yaml
deployments:
    redis:
        architecture: single # (single|replicated) control the jcache profile passed to backend
        external:
            # use external redis instead of local. requires a valid endpoint for redis. compatible with
            # AWS Elasticache and Azure cache for redis.
            # based on redis.architecture value , one of redis.external.endpoint or redis.external.replicatedConfig.nodeAddresses should be configured
            enabled: false
            endpoint: "redis.example.com" # use this if architecture=single.
            replicatedConfig: # an object defines the replicated configuration
                nodeAddresses: [] # MUST have a value if architecture=replicated. otherwise backend won't work. value of FQDNs of reachable nodes
```

### 2.17.4 
- revert add ability allow SHA1 algorithm in keycloak since we move to alpine-based image

### 2.17.3
- replace various init container images with 1 helper image
> [!WARNING]  
>  Chart versions >= 2.17.3 won't work with the old init container `wait-for-keycloak` in the backend configuration. `lightruncom/wait-for-200` has to be replaced with new `lightruncom/chart-helper` in the values.yaml

### 2.17.2
- move from bash to sh in the keycloak init containers

### 2.17.1
- Updated default frontend requirements 

### 2.17.0
- expose liveness and readiness probes timers to values of nginx

### 2.16.0
- expose liveness and readiness probes timers to values of frontend/backend/keycloak/redis/rabbitmq/mysql

### 2.15.0
- add affinity to frontend/backend/keycloak/standalone_nginx/redis/rabbitmq/mysql

### 2.14.0
- add topologySpreadConstraints to frontend/backend/keycloak/standalone_nginx

### 2.13.1
- remove Lightrun version from the server hostname

### 2.13.0

> [!WARNING]
> Lightrun version < 1.26.0 won't be working with chart version < than 2.13.0

- redo keycloak container args for 23 version  
    [more info](https://www.keycloak.org/docs/latest/upgrading/index.html#kc-sh-and-shell-metacharacters)

### 2.12.3

- fix rabbitmq PVC permissions

### 2.12.2

- bug fix - unknown field spec.template.spec.initContainers[0].serviceAccountName

### 2.12.1

- move default rabbitmq image to alpine based

### 2.12.0

- keycloak pod waits until mysql is ready (when .Values.general.db_local is true)
- do not use root user in liveness/readiness mysql probes

### 2.11.0

- add ability allow SHA1 algorithm in keycloak

```yaml
keycloak:
    # Keycloak base image is rhel9 where SHA1 deprecated https://access.redhat.com/articles/6846411.
    # This flag is to re add SHA1 for edge use cases where keycloak works with extenal services
    # that still use SHA1 in their chain. for instance Azure database for MySQL.
    allow_sha1_algorithm: false
```

### 2.10.0

- add ability to configure external redis

```yaml
redis:
    external:
        # use external redis instead of local. requires a valid endpoint for redis. compatible with
        # AWS Elasticache and Azure cache for redis.
        enabled: false
        endpoint: "redis.example.com"
```

### 2.9.2

- add fsGroup for mysql in default values.yaml
- bump default mysql pod version to 8.0.35

```yaml
mysql:
    podSecurityContext:
        # when using PVC , it is necessarily to set fsGroup so mysql will have write permission to the mounted volume
        fsGroup: 1000000
```

### 2.9.1

- bump default mysql pod version to 8.0.33

### 2.9.0

- add ability to configure resources for initContainer of rabbitmq

```yaml
initContainers:
    rabbitmq_config:
        resources:
            cpu: 100m
            memory: 128Mi
```

### 2.8.0

- add ability to configure http and https ports for standalone nginx

```yaml
standalone_nginx:
    ports:
        ## in case there is a need to use privileged ports such as 80/443. to make it work the image.repository should be
        ## replaced to nginx , also podSecurityContext/containerSecurityContext should be set to null
        http: 8080
        https: 8443
```

### 2.7.0

- drop hardcoded user ids from default `securityContext`
- move default `securityContext` to values.yaml `general.base_container_securityContext`
- remove requirement for admin permissions for installation in openshift

### 2.6.2

- add `file:` prefix to encryption key path

### 2.6.1

- add handling of aes key for api keys encryption

```
general:
    api_keys_encryption:
        enabled: false
        key_mount_path: "/keys"

secrets:
    api_keys_encryption:
        aes_key: ""
```

### 2.6.0

- Add `sizeLimit` to emptyDirs:
    1. `/tmp` volumes when `general.readOnlyRootFilesystem: true`  
         Size controlled by the
         ```
         general:
             readOnlyRootFilesystem_tmpfs_sizeLimit: 512Mi
         ```
         Default is 512Mi
    2. Data volumes of rabbitmq, redis, mysql.
         ```
         deployments:
             redis:
                 emptyDir:
                     sizeLimit: 5Gi
         ```
         Rabbitmq uses emptyDir when `mq.storage: 0`  
         In this case volume is not persistant and will use `sizeLimit` of
         ```
         deployments:
             rabbitmq:
                 emptyDir:
                     sizeLimit: 5Gi
         ```
         Mysql will use emptyDir when `statefulset.enabled: false`
         ```
         deployments:
             mysql:
                 emptyDir:
                     sizeLimit: 5Gi
         ```

### 2.5.0

- Add redis authentication

```yaml
deployments:
    redis:
        auth:
            # enable redis authentication .
            # requires secrets.redis.password to not be empty or either provide from external secret
            # requires lightrun version >= 1.19
            enabled: false

secrets:
    redis:
        # redis authentication.
        # requires to enable auth in deployments.redis.auth.enabled by set to true
        password: ""
```

### 2.4.0

- limit access to /auth/realms/lightrun/internal/\*

### 2.3.0

- add `extraVolumes` and `extraVolumeMounts` for backend/frontend/keycloak
- redo `deploy_secrets: false` functionality

old approach:

```yaml
general:
    deploy_secrets: true | false
```

`deploy_secrets` key was only controlling creation of the secrets object, but reference name has to be `{{ .Release.name}}-backend / keycloak`

new approach:

```yaml
deploy_secrets:
    enabled: true
    existing_secrets:
        backend: ""
        keycloak: ""
```

Now you can change default secret name in case that you are creating it outside of the chart

> [!WARNING]  
>  `deploy_secrets` key changed its type from boolean to complex object. Support of the boolean type will be dropped in future versions

### 2.2.4

- bump rabbitmq tag to 3.12.7

### 2.2.3

- bump redis tag to 6.2.14-alpine

### 2.2.2

- expose annotations of all services
- security hardening of standalone nginx (_ingress_conrtoller: false_)

### 2.2.1

- add ability to set custom name of PVCs for mysql and rabbitmq

```yaml
general:
    statefulset:
        pvc_name: ""
    mq:
        pvc_name: ""
```

if empty string, default values will be used:

- `mysql`
- `{{ .Release.name }}-mq-data`

### 2.2.0

- replace separate env vars from backend secret with `envFrom` in backend deployment
- optional secret fields are excluded from the secret in case of empty value

```yaml
secrets:
    defaults:
        google_sso:
            client_id: "" # Optional | If empty, will not be used
            client_secret: "" # Optional | If empty, will not be used
        datadog_api_key: "" # Optional | If empty, will not be used
        mixpanel_token: "" # Optional | If empty, will not be used
        hubspot_token: "" # Optional | If empty, will not be used
```

- add way to create secret with custom name. Will be used if `deploy_secrets: false`

```yaml
general:
    deploy_secrets: false
    existing_secret_name: "new-name"
```

- remove `MANAGEMENT_METRICS_EXPORT_DATADOG_APIKEY` from backend secret Management metrics are available via prometheus endpoint

### 2.1.9

- expose k8s cluster domain to variable in the rabbitmq configuration

### 2.1.8

- add cluster mode for keycloak  
    to enable:

```yaml
deployments:
    keycloak:
        clusterMode: true
```

### 2.1.7

- Rename of the artifact repository env vars:

```
ARTIFACTS_S3_URL -> ARTIFACTS_REPOSITORY_URL
ARTIFACTS_ENABLE_S3_FEATURE -> ARTIFACTS_ENABLE
ARTIFACTS_DOWNLOAD_PRERELEASE -> ARTIFACTS_VERSION_RESOLUTION_MODE
```

- values changes:

```
artifacts:
    s3_url -> repository_url
    download_prerelease -> resolution_mode
```

> **Deprecation note**  
> Old env vars are marked as deprecated and will be removed in future versions of the chart  
> Lightrun versions <= 1.14.0 are using old env vars  
> Lightrun versions >= 1.14.1 have to use chart version >= 2.1.7

### 2.1.6

- Add liveness probes to all pods  
    _redis probe type is chosen based on the chart configuration `internal_tls: enabled`_
- redis configuration provided as configmap
- redis data folder is created as emptyDir with write permissions, for use case when `readOnlyRootFilesystem: true`

### 2.1.5

- Ability not to use docker config secret for authentication to container registry  
    For use cases when private registry do not require authentication

```yaml
secrets:
    defaults:
        dockerhub_config: null
```

### 2.1.4

- add `quote` to all secret fields in backend secret for handling of special characters

### 2.1.3

- handling of the HPA api version. starting form k8s version 1.23 `autoscaling/v2` will be used
- expose init containers images to values for private repositories

### 2.1.2

- add `ARTIFACTS_ENABLE_S3_FEATURE` flag to control external artifact storage. Default `true`

### 2.1.1

- update mysql to `8.0.23`
- update redis to `6.2.13-alpine`
- use rabbitmq image from lightrun repo

### 2.1.0

- Add support for Rabbitmq

### 2.0.5

- Some secret values are optional now (mixpanel, hubspot, etc...)

### 2.0.4

- Add support of Openshift from 1.11

### 2.0.2

- change condition of ingress annotation for HTTPS backend from  
    `eq $.Values.general.ingress_class_name "nginx"` -->  
    `contains "nginx" $.Values.general.ingress_class_name`  
    Useful in case of custom name of ingress class
- replace `$JAVA_HOME` env var with symlink to jdk folder

### 2.0.1

- use http(s) schema helper in templates instead of multiline conditions

## 2.0.0

## Breaking changes :warning:

- Redo keycloak deployment to work with updated version of keycloak image. Versions prior to 1.13.0 are not supported
- Added support of certificate verification with private ca certificate

### 1.13.0-app.3

- add environment variables for the intellij custom repository feature

### 1.13.0-app.2

- minor readme fixes

### 1.13.0-app.1

- add support for mount root filesystem as read-only to frontend/backend/keycloak

### 1.13.0-app.0

- built on top of latest 1.11.0-app.6

### 1.12.0-app.2

- minor readme fixes

### 1.12.0-app.1

- add support for mount root filesystem as read-only to frontend/backend/keycloak

### 1.12.0-app.0

- built on top of latest 1.11.0-app.6

### 1.11.0-app.7

- add support for mount root filesystem as read-only to frontend/backend/keycloak

### 1.11.0-app.6

- add support for TLS communication between pods  
  _TLS support on app side is available from `1.13` version_

### 1.11.0-app.3

- add `imagePullSecrets` to deployments of redis and mysql  

### 1.11.0-app.2

- add support for generic network policy

### 1.11.0-app.1

- default security context for all containers (except user id)

```yaml
runAsNonRoot: true
seccompProfile:
  type: RuntimeDefault
runAsUser: <custom_per_container>
allowPrivilegeEscalation: false
capabilities:
  drop:
    - "ALL"
```

### 1.11.0-app.0

- secrets add ability to provide existing docker hub secret for docker registry
- deployments add ability to add pod security context and container security context
- change default service account to per deployment sa with min permissions
- use non-root user for every pod

### 1.10.0-app.3

- use non-root user for mysql pod
- use lightruncom/mysql image
- use lightruncom/redis image

### 1.10.0-app.2

- add `SPRING_FLYWAY_SCHEMAS` to env vars of the backend

### 1.10.0-app.1

- backend liveness probe timeout increase


### 1.9.0-app.3

- add `db_require_secure_transport` value to enable SSL comunication between backend / keycloakc and DB  
  _Mysql pod will drop connections that aren't using SSL_


### 1.9.0

- allow non-root user to read /p12/lightrun.p12 backend server file


### 1.8.0-app.4

- revert 1.8.0-app.3

### 1.8.0-app.3

- allow non-root user to read /p12/lightrun.p12 backend server file


### 1.8.0-app.2

- add option for hpa for backend and frontend deployments

### 1.8.0-app.1

- config-map for frontend configuration with default port 8080

### 1.8.0-app.0

- annotation of ingresses `kubernetes.io/ingress.class` removed in favor of `ingressClassName` spec field
- added `ingress_class_name` instead

### 1.7.0-app.4

- `_JAVA_OPTIONS` logic with auto calculated heap size

### 1.7.0-app.1

- Expose size of local DB as variable
- add `--skip-lob-bin` in mysql config