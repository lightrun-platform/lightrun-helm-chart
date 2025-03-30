
<a name="v3.14.0"></a>
## [v3.14.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.13.1...v3.14.0) - 2025-03-30



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| artifacts        | 1.55.1-release.6f1f87ac95 |
| backend          | 1.55.1-release.6f1f87ac95 |
| data_streamer    | rpk-4.48.1-alpine         |
| frontend         | 1.55.1-release.6f1f87ac95 |
| keycloak         | 1.55.1-release.6f1f87ac95 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.14-alpine            |
| redis            | alpine-7.2.7-r0           |
| router           | alpine-3.20.0-r1.lr-0     |
| standalone_nginx | stable-alpine-slim        |
 
 


### Changed (6 changes)

- [wait-for-rabbitmq-initcontainer-pass-username-and-password-as-env-vars (#34)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/af0e492)


  The chart-helper tag in the default values.yaml file was updated to 0.3.0-alpine-3.21.3-r0.lr-0 to accommodate the new changes.
 

- [bump-redis-to-7-2-7-alpine-3-21-3-r-0-lr-0 (#35)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/5461370)
 

- [bump-router-to-1-26-3-alpine-3-21-3-r-0-lr-0 (#36)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/ceae413)
 

- [bump-chart-helper-to-0-2-0-alpine-3-21-3-r-0-lr-0 (#37)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/c079422)
 

- [bump-data-streamer-to-4-48-1-alpine-3-21-3-r-0-lr-0 (#38)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/b0a3445)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 

- [keycloak-environment-variables-to-support-keycloak-26.1.4](https://github.com/lightrun-platform/lightrun-helm-chart/commit/8b8a888)
 
 
 


### Documentation (1 change)

- [abstract-documentation (#19)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/7799746)
 
 
 
 

 


<a name="v3.13.1"></a>
## [v3.13.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.13.0...v3.13.1) - 2025-03-17



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.54.2-release.c4f1e2daa7 |
| data_streamer    | rpk-4.48.1-alpine         |
| frontend         | 1.54.2-release.c4f1e2daa7 |
| keycloak         | 1.54.2-release.c4f1e2daa7 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.14-alpine            |
| redis            | alpine-7.2.7-r0           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 


### Changed (1 change)

- [bump-chart-helper-to-0-2-0 (#29)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/c8831c0)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 
 

 


<a name="v3.13.0"></a>
## [v3.13.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.12.0...v3.13.0) - 2025-03-16



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.54.2-release.c4f1e2daa7 |
| data_streamer    | rpk-4.48.1-alpine         |
| frontend         | 1.54.2-release.c4f1e2daa7 |
| keycloak         | 1.54.2-release.c4f1e2daa7 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.14-alpine            |
| redis            | alpine-7.2.7-r0           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 


### Added (2 changes)

- [override-download-endpoint-for-async-profiler-for-internal-mirror-purposes (#28)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/1eefdeb)
 

- [Propose changes to support k8s system diagnostics (#21)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/79e46a2)


  Having "serviceAccount.create: true" is a pre-requisite for this feature to work.
  Otherwise, setting "enabled" to true has no effect.
  When properly enabled, it creates a Role and RoleBinding.
  They allow the backend pod to request k8s API for data about the resources in Lightrun namespace.
  For the backend service account it also enforces mounting the token to the backend pod.
  It must be enabled with caution, because automountServiceAccountToken is not always allowed.
  Note: this parameter doesn't enable or disable the System Diagnostics feature itself.
  It only enables the k8s data collection.
 
 
 
 

 


<a name="v3.12.0"></a>
## [v3.12.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.11.1...v3.12.0) - 2025-03-06



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.53.4-release.b1b8d149c9 |
| data_streamer    | rpk-4.47.1-alpine         |
| frontend         | 1.53.4-release.b1b8d149c9 |
| keycloak         | 1.53.4-release.b1b8d149c9 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.14-alpine            |
| redis            | alpine-7.2.7-r0           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.53.1-release.53d0d289fa |
| data_streamer    | rpk-4.47.1-alpine         |
| frontend         | 1.53.1-release.53d0d289fa |
| keycloak         | 1.53.1-release.53d0d289fa |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.14-alpine            |
| redis            | alpine-7.2.7-r0           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 


### Changed (2 changes)

- [data-streamer version to 4.48.1](https://github.com/lightrun-platform/lightrun-helm-chart/commit/edbf2b8)
 

- [replace-curl-with-wget-command-initcontainers](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2ef907b)
 
 
 
 

 


<a name="v3.11.1"></a>
## [v3.11.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.11.0...v3.11.1) - 2025-02-19



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.52.4-release.7ade04f7f5 |
| data_streamer    | rpk-4.45.1-alpine         |
| frontend         | 1.52.4-release.7ade04f7f5 |
| keycloak         | 1.52.4-release.7ade04f7f5 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 
 

 


<a name="v3.11.0"></a>
## [v3.11.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.10.2...v3.11.0) - 2025-02-16



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.52.3-release.b3d4b46f02 |
| data_streamer    | rpk-4.45.1-alpine         |
| frontend         | 1.52.3-release.b3d4b46f02 |
| keycloak         | 1.52.3-release.b3d4b46f02 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.51.0-release.05d1da7dcc |
| data_streamer    | rpk-4.45.1                |
| frontend         | 1.51.0-release.05d1da7dcc |
| keycloak         | 1.51.0-release.05d1da7dcc |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.51.0-release.05d1da7dcc |
| data_streamer    | rpk-4.37.0                |
| frontend         | 1.51.0-release.05d1da7dcc |
| keycloak         | 1.51.0-release.05d1da7dcc |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 


### Added (2 changes)

- [name-override-support-to-override-release-name (#15)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/7394aaf)
 

- [keystore-password-when-enabling-tls-on-router-level (#6)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/a269810)
 
 
 


### Changed (2 changes)

- [bump-lightrun-redis-to-alpine-7-2-7-r-0 (#12)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/4e866eb)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 

- [data streamer default tag to rpk-4.45.1-alpine (#7)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/026f022)
 
 
 


### Deprecated (1 change)

- [api-keys-encryption (#3)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/0afa21a)


  Co-authored-by: Eliran Barooch <36511676+imeliran@users.noreply.github.com>
  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 
 

 


<a name="v3.10.2"></a>
## [v3.10.2](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.10.1...v3.10.2) - 2025-02-25



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.51.3-release.840a48f088 |
| data_streamer    | rpk-4.45.1                |
| frontend         | 1.51.3-release.840a48f088 |
| keycloak         | 1.51.3-release.840a48f088 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.51.0-release.05d1da7dcc |
| data_streamer    | rpk-4.45.1                |
| frontend         | 1.51.0-release.05d1da7dcc |
| keycloak         | 1.51.0-release.05d1da7dcc |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.51.0-release.05d1da7dcc |
| data_streamer    | rpk-4.37.0                |
| frontend         | 1.51.0-release.05d1da7dcc |
| keycloak         | 1.51.0-release.05d1da7dcc |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 
 

 


<a name="v3.10.1"></a>
## [v3.10.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.10.0...v3.10.1) - 2025-01-28



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.51.0-release.05d1da7dcc |
| data_streamer    | rpk-4.45.1                |
| frontend         | 1.51.0-release.05d1da7dcc |
| keycloak         | 1.51.0-release.05d1da7dcc |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 
 

 


<a name="v3.10.0"></a>
## [v3.10.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.12...v3.10.0) - 2025-01-28



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.51.0-release.05d1da7dcc |
| data_streamer    | rpk-4.37.0                |
| frontend         | 1.51.0-release.05d1da7dcc |
| keycloak         | 1.51.0-release.05d1da7dcc |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 
 

 


<a name="v3.9.12"></a>
## [v3.9.12](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.11...v3.9.12) - 2025-03-13



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.50.6-release.09f2987522 |
| data_streamer    | rpk-4.48.1-alpine         |
| frontend         | 1.50.6-release.09f2987522 |
| keycloak         | 1.50.6-release.09f2987522 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.14-alpine            |
| redis            | alpine-7.2.7-r0           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 
 

 


<a name="v3.9.11"></a>
## [v3.9.11](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.10...v3.9.11) - 2025-03-05



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.50.5-release.946fe1c442 |
| data_streamer    | rpk-4.48.1-alpine         |
| frontend         | 1.50.5-release.946fe1c442 |
| keycloak         | 1.50.5-release.946fe1c442 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.14-alpine            |
| redis            | alpine-7.2.7-r0           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 


### Changed (1 change)

- [bump-versions-in-lts-chart-version-3-9 (#24)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/e8f8605)
 
 
 
 

 


<a name="v3.9.10"></a>
## [v3.9.10](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.9...v3.9.10) - 2025-03-05



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.50.5-release.946fe1c442 |
| data_streamer    | rpk-4.47.1-alpine         |
| frontend         | 1.50.5-release.946fe1c442 |
| keycloak         | 1.50.5-release.946fe1c442 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.7-r0           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 
 

 


<a name="v3.9.9"></a>
## [v3.9.9](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.8...v3.9.9) - 2025-02-12



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.50.5-release.946fe1c442 |
| data_streamer    | rpk-4.45.1-alpine         |
| frontend         | 1.50.5-release.946fe1c442 |
| keycloak         | 1.50.5-release.946fe1c442 |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.7-r0           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 
 

 


<a name="v3.9.8"></a>
## [v3.9.8](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.7...v3.9.8) - 2025-02-11



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.50.4-release.e26f2633fb |
| data_streamer    | rpk-4.45.1-alpine         |
| frontend         | 1.50.4-release.e26f2633fb |
| keycloak         | 1.50.4-release.e26f2633fb |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.7-r0           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 


### Changed (1 change)

- [bump-lightrun-redis-to-alpine-7-2-7-r-0 (#13)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/539d929)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 
 

 


<a name="v3.9.7"></a>
## [v3.9.7](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.6...v3.9.7) - 2025-02-09



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.50.4-release.e26f2633fb |
| data_streamer    | rpk-4.45.1-alpine         |
| frontend         | 1.50.4-release.e26f2633fb |
| keycloak         | 1.50.4-release.e26f2633fb |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |
 
 


### Changed (1 change)

- [bump-datastreamer-tag-to-rpk-4-45-1-alpine (#11)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/5e021a3)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 
 

 


<a name="v3.9.6"></a>
## v3.9.6 - 2025-02-06



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.50.4-release.e26f2633fb |
| data_streamer    | rpk-4.45.1                |
| frontend         | 1.50.4-release.e26f2633fb |
| keycloak         | 1.50.4-release.e26f2633fb |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.50.1-release.ef66f0e08e |
| data_streamer    | rpk-4.45.1                |
| frontend         | 1.50.1-release.ef66f0e08e |
| keycloak         | 1.50.1-release.ef66f0e08e |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.12-alpine            |
| redis            | alpine-7.2.5-r1           |
| router           | alpine-3.20.0-r1          |
| standalone_nginx | stable-alpine-slim        |

| Image               | Tag                      |
|---------------------|--------------------------|
| backend             | 1.50.1-release.ef66f0e08e |
| data_streamer       | rpk-4.37.0               |
| frontend            | 1.50.1-release.ef66f0e08e |
| keycloak            | 1.50.1-release.ef66f0e08e |
| mysql               | 8.0.38                   |
| rabbitmq            | 3.12.12-alpine           |
| redis               | alpine-7.2.5-r1          |
| router              | alpine-3.20.0-r1         |
| standalone_nginx    | stable-alpine-slim       |
 
 


### Changed (1 change)

- [data streamer default tag to rpk-4.45.1-alpine (#7) (#10)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/6b2f1d0)
 
 
 
 

 

 
