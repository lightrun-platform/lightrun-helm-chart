
<a name="v3.26.0"></a>
## [v3.26.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.25.2...v3.26.0) - 2025-09-10



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.67.0-release.f1c147d620    |
| backend       | 1.67.0-release.f1c147d620    |
| crons         | 1.67.0-release.f1c147d620    |
| data_streamer | 4.63.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.67.0-release.f1c147d620    |
| keycloak      | 1.67.0-release.f1c147d620    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |




 
 


### Changed (1 change)

- [keyclock-cache-stack-cp (#134)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/1074aad)
 
 
 


### Fixed (3 changes)

- [broken-link (#132)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/747048d)
 

- [http-scheme (#130)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/e44d77c)
 

- [make-async-profiler-init-container-failures-non-blocking (#126)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2fa1cb1)
 
 
 


### Security (1 change)

- [upgraded-data-streamer-to-4.63.0 (#131)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/cc0d8ba)
 
 
 
 

 


<a name="v3.25.2"></a>
## [v3.25.2](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.25.1...v3.25.2) - 2025-09-09



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.66.2-release.dfa961cafb    |
| backend       | 1.66.2-release.dfa961cafb    |
| crons         | 1.66.2-release.dfa961cafb    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.66.2-release.dfa961cafb    |
| keycloak      | 1.66.2-release.dfa961cafb    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |
 
 
 

 


<a name="v3.25.1"></a>
## [v3.25.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.25.0...v3.25.1) - 2025-08-31



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.66.1-release.d4dc525f84    |
| backend       | 1.66.1-release.d4dc525f84    |
| crons         | 1.66.1-release.d4dc525f84    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.66.1-release.d4dc525f84    |
| keycloak      | 1.66.1-release.d4dc525f84    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |
 
 
 

 


<a name="v3.25.0"></a>
## [v3.25.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.24.1...v3.25.0) - 2025-08-24



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.66.0-release.4f92d4c5d0    |
| backend       | 1.66.0-release.4f92d4c5d0    |
| crons         | 1.66.0-release.4f92d4c5d0    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.66.0-release.4f92d4c5d0    |
| keycloak      | 1.66.0-release.4f92d4c5d0    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |






 
 


### Removed (1 change)

- [tests-from-templates-due-to-helm-ignore-behaivor-during-ci-when-used-during-helm-test (#127)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/e6f6411)
 
 
 


### Added (2 changes)

- [helm-ignore-for-tests-folder-when-packaging-chart (#125)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/403c49c)
 

- [documentation-for-external-rabbitmq-configuration-and-updated-local-rabbitme-docs (#121)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/bdb39c6)
 
 
 


### Fixed (2 changes)

- [data-streamer-cve-by-bumping-version-to-4.61.0-reverted (#124)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/b2b3355)
 

- [data-streamer-cve-by-bumping-version-to-4.61.0 (#123)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/54ba49e)
 
 
 
 

 


<a name="v3.24.1"></a>
## [v3.24.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.24.0...v3.24.1) - 2025-08-17



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.65.1-release.3b872fa607    |
| backend       | 1.65.1-release.3b872fa607    |
| crons         | 1.65.1-release.3b872fa607    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.65.1-release.3b872fa607    |
| keycloak      | 1.65.1-release.3b872fa607    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |
 
 
 

 


<a name="v3.24.0"></a>
## [v3.24.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.23.6...v3.24.0) - 2025-08-11



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.65.0-release.dbbc13e864    |
| backend       | 1.65.0-release.dbbc13e864    |
| crons         | 1.65.0-release.dbbc13e864    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.65.0-release.dbbc13e864    |
| keycloak      | 1.65.0-release.dbbc13e864    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |




 
 


### Changed (2 changes)

- [deprecated-keycloak-env-vars (#122)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/8edcc07)
 

- [bump redis to 7.2.10 (#116)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/ba17dab)
 
 
 
 

 


<a name="v3.23.6"></a>
## [v3.23.6](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.23.5...v3.23.6) - 2025-08-26



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.64.4-release.4d96a911d1    |
| backend       | 1.64.4-release.4d96a911d1    |
| crons         | 1.64.4-release.4d96a911d1    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.64.4-release.4d96a911d1    |
| keycloak      | 1.64.4-release.4d96a911d1    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |
 
 


### Removed (1 change)

- [tests-from-templates-due-to-helm-ignore-behaivor-… (#128)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/1c3b181)
 
 
 


### Changed (1 change)

- [deprecated-keycloak-env-vars (#122) (#129)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/17cf438)
 
 
 
 

 


<a name="v3.23.5"></a>
## [v3.23.5](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.23.4...v3.23.5) - 2025-08-25



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.64.4-release.4d96a911d1    |
| backend       | 1.64.4-release.4d96a911d1    |
| crons         | 1.64.4-release.4d96a911d1    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.64.4-release.4d96a911d1    |
| keycloak      | 1.64.4-release.4d96a911d1    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |
 
 
 

 


<a name="v3.23.4"></a>
## [v3.23.4](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.23.3...v3.23.4) - 2025-08-20



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.64.4-release.4d96a911d1    |
| backend       | 1.64.4-release.4d96a911d1    |
| crons         | 1.64.4-release.4d96a911d1    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.64.4-release.4d96a911d1    |
| keycloak      | 1.64.4-release.4d96a911d1    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |
 
 
 

 


<a name="v3.23.3"></a>
## [v3.23.3](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.23.2...v3.23.3) - 2025-08-12



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.64.3-release.64b0fee50a    |
| backend       | 1.64.3-release.64b0fee50a    |
| crons         | 1.64.3-release.64b0fee50a    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.64.3-release.64b0fee50a    |
| keycloak      | 1.64.3-release.64b0fee50a    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |
 
 
 

 


<a name="v3.23.2"></a>
## [v3.23.2](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.23.1...v3.23.2) - 2025-08-07



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.64.2-release.7b094fb087    |
| backend       | 1.64.2-release.7b094fb087    |
| crons         | 1.64.2-release.7b094fb087    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.64.2-release.7b094fb087    |
| keycloak      | 1.64.2-release.7b094fb087    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |
 
 
 

 


<a name="v3.23.1"></a>
## [v3.23.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.23.0...v3.23.1) - 2025-08-03



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.64.1-release.a32f94ba1e    |
| backend       | 1.64.1-release.a32f94ba1e    |
| crons         | 1.64.1-release.a32f94ba1e    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.64.1-release.a32f94ba1e    |
| keycloak      | 1.64.1-release.a32f94ba1e    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-1 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |
 
 
 

 


<a name="v3.23.0"></a>
## [v3.23.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.22.1...v3.23.0) - 2025-07-30



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.64.0-release.b8a5de8681    |
| backend       | 1.64.0-release.b8a5de8681    |
| crons         | 1.64.0-release.b8a5de8681    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.64.0-release.b8a5de8681    |
| keycloak      | 1.64.0-release.b8a5de8681    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.10-alpine-3.22.0-r0.lr-0 |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |




 
 


### Changed (2 changes)

- [bump redis to 7.2.10 (#116) (#117)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/f6f2a68)
 

- [cron-service-resources (#112)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/5a82985)
 
 
 


### Added (1 change)

- [ratio-capability-when-calculating-heap-size-for-services (#115)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/d849114)
 
 
 
 

 


<a name="v3.22.1"></a>
## [v3.22.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.22.0...v3.22.1) - 2025-07-20



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.63.1-release.45eff1e031    |
| backend       | 1.63.1-release.45eff1e031    |
| crons         | 1.63.1-release.45eff1e031    |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.63.1-release.45eff1e031    |
| keycloak      | 1.63.1-release.45eff1e031    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.9-alpine-3.22.0-r0.lr-0  |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |
 
 
 

 


<a name="v3.22.0"></a>
## [v3.22.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.21.1...v3.22.0) - 2025-07-20



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.63.1-release.45eff1e031    |
| backend       | 1.63.1-release.45eff1e031    |
| crons         |                              |
| data_streamer | 4.56.0-alpine-3.22.0-r0.lr-0 |
| frontend      | 1.63.1-release.45eff1e031    |
| keycloak      | 1.63.1-release.45eff1e031    |
| mysql         | 8.0.38                       |
| rabbitmq      | 4.0.9-alpine-3.22.0-r0.lr-0  |
| redis         | 7.2.9-alpine-3.22.0-r0.lr-0  |
| router        | 1.28.0-alpine-3.22.0-r0.lr-0 |




 
 


### Changed (1 change)

- [cron-service-resources (#112) (#113)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/74c1c64)
 
 
 


### Documentation (1 change)

- [max connections instructions in database.md to account for cron service (#107)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/3bceeba)
 
 
 


### Fixed (2 changes)

- [cron-helper (#111)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/1047bd3)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 

- [rabbitmq-naming-convention (#109)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/3271181)
 
 
 


### Added (1 change)

- [new-crons-service (#106)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/12f79d6)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 


### Security (2 changes)

- [fixing-alpine-cves-in-chart-helper-and-data-streamer (#110)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/555f31f)
 

- [fixing-alpine-cves-in-common-base-image (#108)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/6fc0bab)
 
 
 
 

 


<a name="v3.21.1"></a>
## [v3.21.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.21.0...v3.21.1) - 2025-07-06



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.62.1-release.98c1867bba    |
| backend       | 1.62.1-release.98c1867bba    |
| data_streamer | 4.56.0-alpine-3.21.3-r0.lr-0 |
| frontend      | 1.62.1-release.98c1867bba    |
| keycloak      | 1.62.1-release.98c1867bba    |
| mysql         | 8.0.38                       |
| rabbitmq      | 3.12.14-alpine               |
| redis         | 7.2.9-alpine-3.21.3-r0.lr-0  |
| router        | 1.26.3-alpine-3.21.3-r0.lr-0 |
 
 
 

 


<a name="v3.21.0"></a>
## [v3.21.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.20.0...v3.21.0) - 2025-06-30



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.62.0-release.3e937ac76a    |
| backend       | 1.62.0-release.3e937ac76a    |
| data_streamer | 4.56.0-alpine-3.21.3-r0.lr-0 |
| frontend      | 1.62.0-release.3e937ac76a    |
| keycloak      | 1.62.0-release.3e937ac76a    |
| mysql         | 8.0.38                       |
| rabbitmq      | 3.12.14-alpine               |
| redis         | 7.2.9-alpine-3.21.3-r0.lr-0  |
| router        | 1.26.3-alpine-3.21.3-r0.lr-0 |


 
 


### Removed (1 change)

- [the-option-to-configure-general-system-config-file-path (#92)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/04f938d)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 


### Added (3 changes)

- [salesforce-environment-variables-for-backend (#93)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/ddc29c8)
 

- [artifacts-service-to-lightrun-helm-chart-docs](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2d28a04)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 

- [acl-for-router-status-endpoint (#91)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2312ae2)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 
 

 


<a name="v3.20.0"></a>
## [v3.20.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.19.0...v3.20.0) - 2025-06-22



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.61.0-release.de34f38011    |
| backend       | 1.61.0-release.de34f38011    |
| data_streamer | 4.56.0-alpine-3.21.3-r0.lr-0 |
| frontend      | 1.61.0-release.de34f38011    |
| keycloak      | 1.61.0-release.de34f38011    |
| mysql         | 8.0.38                       |
| rabbitmq      | 3.12.14-alpine               |
| redis         | 7.2.9-alpine-3.21.3-r0.lr-0  |
| router        | 1.26.3-alpine-3.21.3-r0.lr-0 |


 
 


### Changed (2 changes)

- [data-streamer-version-to-4.56.0-alpine-3.21.3-r0.lr-0 (#88)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/fa48e4b)
 

- [upgrade redis to 7.2.9-r0 (#86)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/309d93f)
 
 
 


### Added (1 change)

- [monitoring-and-alerting-guide (#61)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/861addd)
 
 
 
 

 


<a name="v3.19.0"></a>
## [v3.19.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.18.0...v3.19.0) - 2025-06-09



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.60.0-release.209dd9d600    |
| backend       | 1.60.0-release.209dd9d600    |
| data_streamer | 4.55.0-alpine-3.21.3-r0.lr-0 |
| frontend      | 1.60.0-release.209dd9d600    |
| keycloak      | 1.60.0-release.209dd9d600    |
| mysql         | 8.0.38                       |
| rabbitmq      | 3.12.14-alpine               |
| redis         | 7.2.8-alpine-3.21.3-r0.lr-0  |
| router        | 1.26.3-alpine-3.21.3-r0.lr-0 |


 
 


### Changed (4 changes)

- [keycloak-switch-to-statefulset (#80)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/9d80955)
 

- [bump-redis-to-7.2.8-alpine-3.21.3-r0.lr-0 (#77)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/4808155)
 

- [encryption-key-logic-to-be-optional-in-all-cases (#65)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/5d1d456)
 

- [encryption-key-logic-to-not-fail-when-key-does-not-exist (#64)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/719cf2a)
 
 
 


### Fixed (2 changes)

- [cves-in-data-streamer-by-bumping-version-to-4.55.0 (#74)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/eb781e6)
 

- [not-create-system-configuration-if-content-and-signature-empty (#71)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/db1bcc7)
 
 
 


### Added (2 changes)

- [system-config (#69)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/47cc7d1)


  Add System Configuration feature
  
  Introduce system configuration support for advanced Lightrun server settings.
  The feature allows providing a signed JSON config file through ConfigMap.
  Documentation available at docs/advanced/system_config.md
 

- [openai-admin-api-key-support (#67)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/f9a9b85)
 
 
 
 

 


<a name="v3.18.0"></a>
## [v3.18.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.17.0...v3.18.0) - 2025-05-27



### Versions

| Image         | Tag                          |
|---------------|------------------------------|
| artifacts     | 1.59.0-release.50ad36cad6    |
| backend       | 1.59.0-release.50ad36cad6    |
| data_streamer | 4.54.1-alpine-3.21.3-r0.lr-0 |
| frontend      | 1.59.0-release.50ad36cad6    |
| keycloak      | 1.59.0-release.50ad36cad6    |
| mysql         | 8.0.38                       |
| rabbitmq      | 3.12.14-alpine               |
| redis         | 7.2.8-alpine-3.21.3-r0.lr-0  |
| router        | 1.26.3-alpine-3.21.3-r0.lr-0 |






 
 


### Changed (2 changes)

- [bump-redis-to-7.2.8-alpine-3.21.3-r0.lr-0 (#77) (#79)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/c8c3d80)
 

- [encryption-key-logic-to-be-optional-in-all-cases … (#66)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/baa25c2)
 
 
 


### Fixed (1 change)

- [not-create-system-configuration-if-content-and-signature-empty](https://github.com/lightrun-platform/lightrun-helm-chart/commit/cafa544)
 
 
 


### Added (5 changes)

- [system-config (#70)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/4c7fe5e)


  Add System Configuration feature
  
  Introduce system configuration support for advanced Lightrun server settings. The feature allows providing a signed JSON config file through ConfigMap. Documentation available at docs/advanced/system_config.md
 

- [openai-admin-api-key-support (#67) (#68)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/7127c0d)
 

- [keycloak-queue-name-to-backend-deployment-for-keycloak-events-feature (#62)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/c8d0f51)
 

- [support-for-user-key-encryption (#58)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/a42004d)
 

- [missing-params-for-supporting-keycloak-events-queue (#59)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/7c5764a)
 
 
 


### Removed (1 change)

- [hubspot-integration (#63)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/4a12292)
 
 
 


### Deprecated (1 change)

- [standalone-nginx-and-old-approach-of-ingress-per-svc (#60)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2d9d378)
 
 
 
 

 


<a name="v3.17.0"></a>
## [v3.17.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.16.8...v3.17.0) - 2025-05-11



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.58.1-release.a4f3b6a620    |
| backend          | 1.58.1-release.a4f3b6a620    |
| data_streamer    | 4.54.1-alpine-3.21.3-r0.lr-0 |
| frontend         | 1.58.1-release.a4f3b6a620    |
| keycloak         | 1.58.1-release.a4f3b6a620    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.7-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |




 
 


### Changed (3 changes)

- [upgrade data-streamer to 4.54.1-alpine-3.21.3-r0.… (#55)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/ba4f568)
 

- [chart docs minor fixes (#51)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2b30c51)
 

- [pod-resource-requests-of-backend-pod-to-fit-into-… (#50)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/74d623c)
 
 
 


### Added (2 changes)

- [keycloak-events-queue-in-rabbitmq (#47)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2863cf3)
 

- [Support lightrun_init_sys_api_key secret (#48)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/e9533a0)
 
 
 
 

 


<a name="v3.16.8"></a>
## [v3.16.8](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.16.7...v3.16.8) - 2025-08-07



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.57.7-release.01d79cc4cd    |
| backend          | 1.57.7-release.01d79cc4cd    |
| data_streamer    | 4.55.0-alpine-3.21.3-r0.lr-0 |
| frontend         | 1.57.7-release.01d79cc4cd    |
| keycloak         | 1.57.7-release.01d79cc4cd    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.8-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |
 
 
 

 


<a name="v3.16.7"></a>
## [v3.16.7](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.16.6...v3.16.7) - 2025-07-28



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.57.6-release.28c0abba53    |
| backend          | 1.57.6-release.28c0abba53    |
| data_streamer    | 4.55.0-alpine-3.21.3-r0.lr-0 |
| frontend         | 1.57.6-release.28c0abba53    |
| keycloak         | 1.57.6-release.28c0abba53    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.8-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |
 
 
 

 


<a name="v3.16.6"></a>
## [v3.16.6](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.16.5...v3.16.6) - 2025-07-06



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.57.5-release.8e2c9a0d3d    |
| backend          | 1.57.5-release.8e2c9a0d3d    |
| data_streamer    | 4.55.0-alpine-3.21.3-r0.lr-0 |
| frontend         | 1.57.5-release.8e2c9a0d3d    |
| keycloak         | 1.57.5-release.8e2c9a0d3d    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.8-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |
 
 


### Removed (1 change)

- [the-option-to-configure-general-system-config-file-path](https://github.com/lightrun-platform/lightrun-helm-chart/commit/774a216)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 


### Added (1 change)

- [helm-chart-validation-pipeline](https://github.com/lightrun-platform/lightrun-helm-chart/commit/6664cd9)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 
 

 


<a name="v3.16.5"></a>
## [v3.16.5](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.16.4...v3.16.5) - 2025-05-28



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.57.4-release.55788b7735    |
| backend          | 1.57.4-release.55788b7735    |
| data_streamer    | 4.55.0-alpine-3.21.3-r0.lr-0 |
| frontend         | 1.57.4-release.55788b7735    |
| keycloak         | 1.57.4-release.55788b7735    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.8-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |
 
 


### Fixed (1 change)

- [chart-template-errors-in-backend (#83)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/0881e57)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 
 

 


<a name="v3.16.4"></a>
## [v3.16.4](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.16.3...v3.16.4) - 2025-05-28



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.57.4-release.55788b7735    |
| backend          | 1.57.4-release.55788b7735    |
| data_streamer    | 4.55.0-alpine-3.21.3-r0.lr-0 |
| frontend         | 1.57.4-release.55788b7735    |
| keycloak         | 1.57.4-release.55788b7735    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.8-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |
 
 


### Changed (2 changes)

- [keycloak-switch-to-statefulset (#81)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/c9ce235)
 

- [bump-redis-to-7.2.8-alpine-3.21.3-r0.lr-0 (#77) (#78)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/6c2f377)
 
 
 


### Fixed (1 change)

- [cves-in-data-streamer-by-bumping-version-to-4.55.0-cp (#76)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2999495)
 
 
 
 

 


<a name="v3.16.3"></a>
## [v3.16.3](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.16.2...v3.16.3) - 2025-05-19



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.57.3-release.9168ae5ade    |
| backend          | 1.57.3-release.9168ae5ade    |
| data_streamer    | 4.54.1-alpine-3.21.3-r0.lr-0 |
| frontend         | 1.57.3-release.9168ae5ade    |
| keycloak         | 1.57.3-release.9168ae5ade    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.7-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |
 
 


### Added (1 change)

- [system-config (#75)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/14432ee)
 
 
 
 

 


<a name="v3.16.2"></a>
## [v3.16.2](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.16.1...v3.16.2) - 2025-05-06



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.57.3-release.9168ae5ade    |
| backend          | 1.57.3-release.9168ae5ade    |
| data_streamer    | 4.54.1-alpine-3.21.3-r0.lr-0 |
| frontend         | 1.57.3-release.9168ae5ade    |
| keycloak         | 1.57.3-release.9168ae5ade    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.7-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |
 
 
 

 


<a name="v3.16.1"></a>
## [v3.16.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.16.0...v3.16.1) - 2025-05-06



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.57.2-release.b6e255c052    |
| backend          | 1.57.2-release.b6e255c052    |
| data_streamer    | 4.54.1-alpine-3.21.3-r0.lr-0 |
| frontend         | 1.57.2-release.b6e255c052    |
| keycloak         | 1.57.2-release.b6e255c052    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.7-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |
 
 


### Changed (2 changes)

- [upgrade data-streamer to 4.54.1-alpine-3.21.3-r0.… (#57)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/c791396)
 

- [pod-resource-requests-of-backend-pod-to-fit-into-… (#52)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/99dbaf3)


  Co-authored-by: Tal Yitzhak <taly@lightrun.com>
 
 
 
 

 


<a name="v3.16.0"></a>
## [v3.16.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.15.1...v3.16.0) - 2025-04-27



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.57.1-release.e5e0c8e7c4    |
| backend          | 1.57.1-release.e5e0c8e7c4    |
| data_streamer    | 4.51-alpine-3.21.3-r0.lr-0   |
| frontend         | 1.57.1-release.e5e0c8e7c4    |
| keycloak         | 1.57.1-release.e5e0c8e7c4    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.7-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |


 
 


### Added (3 changes)

- [Support lightrun_init_sys_api_key secret (#48) (#49)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/95872b4)
 

- [documentation-for-setting-up-external-redis-with-redis-ent-operator-with-openshift (#45)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/83a5643)
 

- [documentation-for-system-diagnostics-k8s-api-enablement (#44)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/1af8d5b)
 
 
 
 

 


<a name="v3.15.1"></a>
## [v3.15.1](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.15.0...v3.15.1) - 2025-04-22



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.56.2-release.36f0cd23dc    |
| backend          | 1.56.2-release.36f0cd23dc    |
| data_streamer    | 4.51-alpine-3.21.3-r0.lr-0   |
| frontend         | 1.56.2-release.36f0cd23dc    |
| keycloak         | 1.56.2-release.36f0cd23dc    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.7-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |
 
 
 

 


<a name="v3.15.0"></a>
## [v3.15.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.14.0...v3.15.0) - 2025-04-14



### Versions

| Image            | Tag                          |
|------------------|------------------------------|
| artifacts        | 1.56.1-release.2b70fb9fe6    |
| backend          | 1.56.1-release.2b70fb9fe6    |
| data_streamer    | 4.51-alpine-3.21.3-r0.lr-0   |
| frontend         | 1.56.1-release.2b70fb9fe6    |
| keycloak         | 1.56.1-release.2b70fb9fe6    |
| mysql            | 8.0.38                       |
| rabbitmq         | 3.12.14-alpine               |
| redis            | 7.2.7-alpine-3.21.3-r0.lr-0  |
| router           | 1.26.3-alpine-3.21.3-r0.lr-0 |
| standalone_nginx | stable-alpine-slim           |


 
 


### Changed (7 changes)

- [bumped-data-streamer-version (#43)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/19c76d3)
 

- [enable-the-router-nginx-stub-status (#41)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/2726534)
 

- [wait-for-rabbitmq-initcontainer-pass-username-and-password-as-env-vars (#34)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/9418edb)


  The chart-helper tag in the default values.yaml file was updated to 0.3.0-alpine-3.21.3-r0.lr-0 to accommodate the new changes.
 

- [bump-redis-to-7-2-7-alpine-3-21-3-r-0-lr-0 (#35)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/3e811b7)
 

- [bump-router-to-1-26-3-alpine-3-21-3-r-0-lr-0 (#36)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/e710774)
 

- [bump-chart-helper-to-0-2-0-alpine-3-21-3-r-0-lr-0 (#37)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/92eb5af)
 

- [bump-data-streamer-to-4-48-1-alpine-3-21-3-r-0-lr-0 (#38)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/264c753)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 


### Added (1 change)

- [http-header-to-frontend-for-clickjacking-protection (#42)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/a3e2744)
 
 
 


### Documentation (1 change)

- [abstract-documentation (#19)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/be1bc38)
 
 
 
 

 


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




 
 


### Changed (2 changes)

- [keycloak-environment-variables-to-support-keycloak-26.1.4](https://github.com/lightrun-platform/lightrun-helm-chart/commit/bc41ad9)
 

- [bump-chart-helper-to-0-2-0 (#29)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/4069a60)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 


### Added (1 change)

- [override-download-endpoint-for-async-profiler-for-internal-mirror-purposes (#28)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/da34c54)
 
 
 
 

 


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

- [bump-chart-helper-to-0-2-0 (#29) (#30)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/a8b5507)


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






 
 


### Added (1 change)

- [Propose changes to support k8s system diagnostics (#21)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/1d03bf9)


  Having "serviceAccount.create: true" is a pre-requisite for this feature to work.
  Otherwise, setting "enabled" to true has no effect.
  When properly enabled, it creates a Role and RoleBinding.
  They allow the backend pod to request k8s API for data about the resources in Lightrun namespace.
  For the backend service account it also enforces mounting the token to the backend pod.
  It must be enabled with caution, because automountServiceAccountToken is not always allowed.
  Note: this parameter doesn't enable or disable the System Diagnostics feature itself.
  It only enables the k8s data collection.
 
 
 


### Changed (2 changes)

- [data-streamer version to 4.48.1](https://github.com/lightrun-platform/lightrun-helm-chart/commit/be66647)
 

- [replace-curl-with-wget-command-initcontainers](https://github.com/lightrun-platform/lightrun-helm-chart/commit/80e561b)
 
 
 
 

 


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




 
 


### Added (1 change)

- [name-override-support-to-override-release-name (#15)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/f52f772)
 
 
 


### Changed (1 change)

- [bump-lightrun-redis-to-alpine-7-2-7-r-0 (#12)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/09f9953)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 
 

 


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




 
 


### Changed (1 change)

- [data streamer default tag to rpk-4.45.1-alpine (#7)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/baf649b)
 
 
 


### Deprecated (1 change)

- [api-keys-encryption (#3)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/b650b2c)


  Co-authored-by: Eliran Barooch <36511676+imeliran@users.noreply.github.com>
  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 


### Added (1 change)

- [keystore-password-when-enabling-tls-on-router-level (#6)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/5565333)
 
 
 
 

 


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
## [v3.10.0](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.13...v3.10.0) - 2025-03-30



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
 
 
 

 


<a name="v3.9.13"></a>
## [v3.9.13](https://github.com/lightrun-platform/lightrun-helm-chart/compare/v3.9.12...v3.9.13) - 2025-04-20



### Versions

| Image            | Tag                       |
|------------------|---------------------------|
| backend          | 1.50.7-release.846df2025e |
| data_streamer    | rpk-4.48.1-alpine         |
| frontend         | 1.50.7-release.846df2025e |
| keycloak         | 1.50.7-release.846df2025e |
| mysql            | 8.0.38                    |
| rabbitmq         | 3.12.14-alpine            |
| redis            | alpine-7.2.7-r0           |
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

- [bump-versions-in-lts-chart-version-3-9 (#24)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/0de9a93)
 
 
 
 

 


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

- [bump-lightrun-redis-to-alpine-7-2-7-r-0 (#13)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/4d4aef2)


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

- [bump-datastreamer-tag-to-rpk-4-45-1-alpine (#11)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/d8ae605)


  Co-authored-by: eliranb <eliranb@lightrun.com>
 
 
 
 

 


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
 
 


### Changed (1 change)

- [data streamer default tag to rpk-4.45.1-alpine (#7) (#10)](https://github.com/lightrun-platform/lightrun-helm-chart/commit/99d5d09)
 
 
 
 

 


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
 
 
 

 

 
