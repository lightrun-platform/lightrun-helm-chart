# Capacity Planning Guidelines

This page provides capacity planning guidelines for deploying and scaling infrastructure based on the number of Lightrun agents in a system. It includes details on required resources, instance types, and configurations for different cloud providers (AWS, Azure, and GCP). The goal is to ensure optimal performance and resource utilization while maintaining high availability.


> [!NOTE]
> If you intend to deploy all services, including MySQL and Redis, within the cluster (not recommended for production), keep in mind that each service will run with **a single replica** (no high availability). To fit all services, you must allocate at least **9 vCPUs** and **25 GiB of memory**.


The capacity planning estimates include:

- **Application Pods**: Compute and memory resources required for each component.
    
- **Kubernetes Worker Nodes**: Compute instances needed to support the workload.
    
- **Managed Services**: Database and Redis services specifications.
## Capacity Planning Table
> [!NOTE]
> The capacity planning do not include k8s reserved resources, such as kube-reserved, system-reserved, and eviction threshold.

### Scaling by Agent Count

The following table outlines resource allocations based on different agent counts:

| Agents   | Router Pods         | Frontend Pods       | Backend Pods     | Keycloak Pods   | Datastreamer Pods   | RabbitMQ Pods     | Kubernetes Worker Nodes            | Managed MySQL                                                       | Managed Redis                                                       |
| -------- | ------------------- | ------------------- | ---------------- | --------------- | ------------------- | ----------------- | ---------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **1K**   | 1 (0.3 vCPU, 256Mb) | 1 (0.1 vCPU, 128Mb) | 1 (3 vCPU, 7GB)  | 1 (1 vCPU, 2GB) | 1 (0.1 vCPU, 128MB) | 1 (0.5 vCPU, 1GB) | 2 (4 vCPU, 8GB memory, 10 GB disk) | db.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP)    | cache.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP) |
| **5K**   | 2 (0.3 vCPU, 256Mb) | 2 (0.1 vCPU, 128Mb) | 2 (3 vCPU, 7GB)  | 2 (1 vCPU, 2GB) | 2 (0.1 vCPU, 128MB) | 3 (0.5 vCPU, 1GB) | 4 (4 vCPU, 8GB, 10 GB disk)        | db.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP)    | cache.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP) |
| **7.5K** | 2 (0.3 vCPU, 256Mb) | 2 (0.1 vCPU, 128Mb) | 3 (3 vCPU, 7GB)  | 2 (1 vCPU, 2GB) | 2 (0.1 vCPU, 128MB) | 3 (0.5 vCPU, 1GB) | 5 (4 vCPU, 8GB, 10 GB disk)        | db.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP)    | cache.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP) |
| **10K**  | 2 (0.3 vCPU, 256Mb) | 2 (0.1 vCPU, 128Mb) | 4 (3 vCPU, 7GB)  | 2 (1 vCPU, 2GB) | 2 (0.1 vCPU, 128MB) | 3 (0.5 vCPU, 1GB) | 6 (4 vCPU, 8GB, 10 GB disk)        | db.m7g.xlarge (AWS), Standard_D4as_v5 (Azure), n2-standard-4 (GCP)  | cache.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP) |
| **15K**  | 2 (0.3 vCPU, 256Mb) | 2 (0.1 vCPU, 128Mb) | 5 (3 vCPU, 7GB)  | 2 (1 vCPU, 2GB) | 2 (0.1 vCPU, 128MB) | 3 (0.5 vCPU, 1GB) | 7 (4 vCPU, 8GB, 10 GB disk)        | db.m7g.xlarge (AWS), Standard_D4as_v5 (Azure), n2-standard-4 (GCP)  | cache.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP) |
| **20K**  | 2 (0.3 vCPU, 256Mb) | 2 (0.1 vCPU, 128Mb) | 7 (3 vCPU, 7GB)  | 2 (1 vCPU, 2GB) | 2 (0.1 vCPU, 128MB) | 3 (0.5 vCPU, 1GB) | 9 (4 vCPU, 8GB, 10 GB disk)        | db.m7g.xlarge (AWS), Standard_D4as_v5 (Azure), n2-standard-4 (GCP)  | cache.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP) |
| **25K**  | 2 (0.3 vCPU, 256Mb) | 2 (0.1 vCPU, 128Mb) | 9 (3 vCPU, 7GB)  | 2 (1 vCPU, 2GB) | 2 (0.1 vCPU, 128MB) | 3 (0.5 vCPU, 1GB) | 11 (4 vCPU, 8GB, 10 GB disk)       | db.m7g.2xlarge (AWS), Standard_D8as_v5 (Azure), n2-standard-8 (GCP) | cache.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP) |
| **30K**  | 2 (0.3 vCPU, 256Mb) | 2 (0.1 vCPU, 128Mb) | 10 (3 vCPU, 7GB) | 2 (1 vCPU, 2GB) | 2 (0.1 vCPU, 128MB) | 3 (0.5 vCPU, 1GB) | 12 (4 vCPU, 8GB, 10 GB disk)       | db.m7g.2xlarge (AWS), Standard_D8as_v5 (Azure), n2-standard-8 (GCP) | cache.m7g.large (AWS), Standard_D2s_v3 (Azure), n2-standard-2 (GCP) |

Capacity planning should be done in coordination with Lightrun Support Engineers.

