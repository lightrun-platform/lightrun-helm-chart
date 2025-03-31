
<a name="v3.13.1"></a>
## [v3.13.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.13.0...v3.13.1) - 2025-03-17



### Changed (1 change)

- [bump-chart-helper-to-0-2-0 ([#29](https://github.com/lightrun-platform/lightrun-helm-chart/issues/29)) ([#30](https://github.com/lightrun-platform/lightrun-helm-chart/issues/30))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/9c5ea55)


  Co-authored-by: eliranb <eliranb[@lightrun](https://github.com/lightrun).com>
 
 
 


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
 
 
 

 


<a name="v3.13.0"></a>
## [v3.13.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.12.0...v3.13.0) - 2025-03-16



### Added (1 change)

- [Propose changes to support k8s system diagnostics ([#21](https://github.com/lightrun-platform/lightrun-helm-chart/issues/21))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/ec03d4f)


  Having "serviceAccount.create: true" is a pre-requisite for this feature to work.
  Otherwise, setting "enabled" to true has no effect.
  When properly enabled, it creates a Role and RoleBinding.
  They allow the backend pod to request k8s API for data about the resources in Lightrun namespace.
  For the backend service account it also enforces mounting the token to the backend pod.
  It must be enabled with caution, because automountServiceAccountToken is not always allowed.
  Note: this parameter doesn't enable or disable the System Diagnostics feature itself.
  It only enables the k8s data collection.
 
 
 


### Changed (2 changes)

- [data-streamer version to 4.48.1](https://github.com/lightrun-platform/lightrun-helm-chart/commit/02984d9)
 

- [replace-curl-with-wget-command-initcontainers](https://github.com/lightrun-platform/lightrun-helm-chart/commit/ab642dc)
 
 
 


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






 
 
 

 


<a name="v3.12.0"></a>
## [v3.12.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.11.1...v3.12.0) - 2025-03-06



### Added (1 change)

- [name-override-support-to-override-release-name ([#15](https://github.com/lightrun-platform/lightrun-helm-chart/issues/15))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2f8415b)
 
 
 


### Changed (1 change)

- [bump-lightrun-redis-to-alpine-7-2-7-r-0 ([#12](https://github.com/lightrun-platform/lightrun-helm-chart/issues/12))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/451e27d)


  Co-authored-by: eliranb <eliranb[@lightrun](https://github.com/lightrun).com>
 
 
 


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



### Added (1 change)

- [keystore-password-when-enabling-tls-on-router-level ([#6](https://github.com/lightrun-platform/lightrun-helm-chart/issues/6))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/c3e1dad)
 
 
 


### Changed (1 change)

- [data streamer default tag to rpk-4.45.1-alpine ([#7](https://github.com/lightrun-platform/lightrun-helm-chart/issues/7))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2797faf)
 
 
 


### Deprecated (1 change)

- [api-keys-encryption ([#3](https://github.com/lightrun-platform/lightrun-helm-chart/issues/3))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/7795d6b)


  Co-authored-by: Eliran Barooch <36511676+imeliran[@users](https://github.com/users).noreply.github.com>
  Co-authored-by: eliranb <eliranb[@lightrun](https://github.com/lightrun).com>
 
 
 


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
 
 
 

 


<a name="v3.10.1"></a>
## [v3.10.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.10.0...v3.10.1) - 2025-03-30



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
## [v3.10.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.12...v3.10.0) - 2025-03-30



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



### Changed (1 change)

- [bump-versions-in-lts-chart-version-3-9 ([#24](https://github.com/lightrun-platform/lightrun-helm-chart/issues/24))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/e8f8605)
 
 
 


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



### Changed (1 change)

- [bump-lightrun-redis-to-alpine-7-2-7-r-0 ([#13](https://github.com/lightrun-platform/lightrun-helm-chart/issues/13))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/539d929)


  Co-authored-by: eliranb <eliranb[@lightrun](https://github.com/lightrun).com>
 
 
 


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
 
 
 

 


<a name="v3.9.7"></a>
## [v3.9.7](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.6...v3.9.7) - 2025-02-09



### Changed (1 change)

- [bump-datastreamer-tag-to-rpk-4-45-1-alpine ([#11](https://github.com/lightrun-platform/lightrun-helm-chart/issues/11))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/5e021a3)


  Co-authored-by: eliranb <eliranb[@lightrun](https://github.com/lightrun).com>
 
 
 


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
 
 
 

 


<a name="v3.9.6"></a>
## [v3.9.6](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.5...v3.9.6) - 2025-02-06



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
 
 
 

 


<a name="v3.9.5"></a>
## [v3.9.5](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.4...v3.9.5) - 2025-03-30



### Changed (1 change)

- [data streamer default tag to rpk-4.45.1-alpine ([#7](https://github.com/lightrun-platform/lightrun-helm-chart/issues/7)) ([#10](https://github.com/lightrun-platform/lightrun-helm-chart/issues/10))](https://github.com/lightrun-platform/lightrun-helm-chart/commit/6b2f1d0)
 
 
 


### Versions

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
 
 
 

 


<a name="v3.9.4"></a>
## v3.9.4 - 2025-03-30



### Versions

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
 
 
 

 

 
