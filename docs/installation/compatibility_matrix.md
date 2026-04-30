# Lighturn Compatibility with Kubernetes and OpenShift

This page provides a compatibility overview for Kubernetes and OpenShift versions with the Helm charts in this repository.

## Helm Compatibility
```
 >= 3.17.0 
```
## Kubernetes Compatibility

| Kubernetes Release | Compatibility | Comments |
| ------------------ | ------------- | -------- |
| 1.34               | Compatible    |          |
| 1.33               | Compatible    |          |
| 1.32               | Compatible    |          |
| 1.31               | Compatible    |          |
| 1.30               | Compatible    |          |
| 1.29               | Compatible    |          |

> **Note on older Kubernetes versions (< 1.30):** These versions are no longer offered by major cloud providers ([EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html), [GKE](https://cloud.google.com/kubernetes-engine/docs/release-schedule), [AKS](https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions)) and are therefore not included in our test matrix. The chart may still function correctly on older releases, but compatibility is not guaranteed and these versions are not officially supported.

## OpenShift Compatibility

| OpenShift Version | Compatibility | Comments |
| ----------------- | ------------- | -------- |
| 4.21              | Compatible    |          |
| 4.20              | Compatible    |          |
| 4.19              | Compatible    |          |
| 4.18              | Compatible    |          |

> **Note on older OpenShift versions (< 4.18):** These versions are no longer available on major cloud providers and are therefore not included in our test matrix. The chart may still function correctly on older releases, but compatibility is not guaranteed and these versions are not officially supported. For the full Red Hat OpenShift life cycle policy, see the [OpenShift Container Platform Life Cycle](https://access.redhat.com/support/policy/updates/openshift) page.