# MySQL
This page describes how to configure **MySQL** as the database. The following methods are supported:  
-  Deploy a [**Local MySQL (`general.db_local true`)**](#local-mysql-generaldb_local-true).  
- Connect to an [**External MySQL (`general.db_local false`)**](#external-mysql-generaldb_local-false).

> [!Note] 
> **To enable SSL for both local and external MySQL instances, set `general.db_require_secure_transport: true`, which enforces secure connections by passing `require_secure_transport=ON` to the MySQL pod (`db_local=true`) and configuring backend services, including Keycloak, to use SSL when connecting to the database.**
## **External MySQL (`general.db_local: false`)**
In this mode, MySQL is **not deployed inside the cluster**.  
Instead, the application connects to an **existing MySQL database**.

### **Required MySQL Server Configuration**

Before using an external MySQL database, you MUST configure the following server settings and create the database:


| System Variable                                                                                                                                        | Required Value                                 | Description                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------- | ------------------------------------------------------------------------------- |
| [`sql_generate_invisible_primary_key`](https://dev.mysql.com/doc/refman/8.4/en/server-system-variables.html#sysvar_sql_generate_invisible_primary_key) | `0`                                            | Must be **OFF** to avoid invisible primary keys.                                |
| [`lower_case_table_names`](https://dev.mysql.com/doc/refman/8.4/en/server-system-variables.html#sysvar_lower_case_table_names)                         | `1`                                            | Must be **ON** to ensure table name consistency.                                |
| [`max_connections`](https://dev.mysql.com/doc/refman/8.4/en/server-system-variables.html#sysvar_max_connections)                                       | `100 * (# of backends) + 10 * (# of Keycloak)` | Must be set according to the number of backend services and Keycloak instances. |
| [`character_set_server`](https://dev.mysql.com/doc/refman/8.4/en/server-system-variables.html#sysvar_character_set_server)                             | `utf8mb4`                                      | Must be set to `utf8mb4` for full Unicode support.                              |

**Pre-created Database Requirement:**  
The target MySQL database **must be created in advance** and should match the value of `general.db_database`. The application will not create the database automatically.
**Example command to create the database:**

```sql
CREATE DATABASE lightrunserver;
```

[//]:  # (TODO add verification deploymets, known tested configuration)

---

### **[MANDATORY] External Database Requirements**

- **MySQL Version**: `>= 8.0.37`
- **Database Size**: CPU, Memory, and Disk must meet [**capacity table requirements**](../installation/capacity_planning.md).
- **Database Engine**: **Must be MySQL** (MySQL-compatible databases like **Aurora are NOT supported**).
---

### **[OPTIONAL] High Availability (HA) Recommendations**

While **not required**, the following HA settings are **recommended** for production:

- **Multi-AZ Deployment** for redundancy  
- **Source-Replica Replication** (not cluster mode)  
- **No Cluster Mode** (Avoid Galera, InnoDB Cluster, etc.)

### **Helm Chart Configuration**
```yaml
general:
  db_local: false
  db_endpoint: "mysql.external.example.com"
  db_database: lightrunserver
```

| Property                                              | Description                                          |
| ----------------------------------------------------- | ---------------------------------------------------- |
| **`general.db_local: false`**                         | Disables in-cluster MySQL deployment.                |
| **`general.db_endpoint: mysql.external.example.com`** | **External MySQL host** for the application.         |
| **`general.db_database: lightrunserver`**             | Name of the database in the external MySQL instance. |

## **Local MySQL (`general.db_local: true`)**
In this mode, MySQL is deployed **inside the cluster** using either:  
- A **StatefulSet** with persistent storage (**Recommended**)  
- A **Deployment** with ephemeral storage (for testing purposes)
### **Basic Configuration**
```yaml
general:
  db_local: true
  db_database: lightrunserver
  db_require_secure_transport: false

```

| Property                                         | Description                                             |
| ------------------------------------------------ | ------------------------------------------------------- |
| **`general.db_local: true`**                     | Deploys MySQL inside the cluster.                       |
| **`general.db_database: lightrunserver`**        | The name of the MySQL database.                         |
| **`general.db_require_secure_transport: false`** | If `true`, enables **SSL (TLS)** for MySQL connections. |
### **Persistent vs. Ephemeral Storage**

#### **Option 1: Persistent Storage (StatefulSet Enabled)**

- Uses **PersistentVolumeClaim (PVC)**
- **Data is retained** across restarts
```yaml
general:
  statefulset:
    enabled: true
    storageClassName: "gp3"
    storageSize: 100Gi
```

|Property|Description|
|---|---|
|**`enabled: true`**|Enables StatefulSet (persistent storage).|
|**`storageClassName: gp3`**|Storage class for the PVC.|
|**`storageSize: 100Gi`**|Storage allocated for MySQL.|

---

####  **Option 2: Ephemeral Storage (StatefulSet Disabled)**
> **⚠️ Recommended for testing only!**
- Uses **`emptyDir`** (non-persistent storage)
- **Data is lost** if the pod restarts
```yaml
general:
  statefulset:
    enabled: false
deployments:
  mysql:
    emptyDir:
      sizeLimit: 5Gi
```

| Property                                        | Description                                      |
| ----------------------------------------------- | ------------------------------------------------ |
| **`general.statefulset.enabled: false`**        | MySQL runs as a **Deployment** (non-persistent). |
| **`deployments.emptyDir.mysql.sizeLimit: 5Gi`** | Limits ephemeral storage to 5Gi.                 |

### **Pod Configuration**
This is the **default MySQL pod configuration**.
Configuration is defined under **`deployments.mysql`** in the **`values.yaml`** file.
```yaml
deployments:
  mysql:
    nodeSelector: {}
    podSecurityContext:
      # When using a PVC, it is necessary to set fsGroup to ensure the pod has write permissions to the mounted volume.
      # The fsGroup should be aligned with the runAsUser of the container.
      fsGroup: 1000000
    containerSecurityContext: {}
    image:
      repository: mysql
      tag: 8.0.38
      pullPolicy: IfNotPresent
    resources:
      cpu: 2000m
      memory: 8Gi
    podLabels: {}
    podAnnotations: {}
    annotations: {} # deprecated in favor of podAnnotations
    service:
      annotations: {}
      labels: {}
    # In case of db_local=true and statefulset.enabled=false
    # non-persistent emptyDir is used for mysql data
    emptyDir:
      sizeLimit: 5Gi
    affinity: {}
    livenessProbe:
      initialDelaySeconds: 200
      periodSeconds: 30
      timeoutSeconds: 10
      successThreshold: 1
      failureThreshold: 3
    readinessProbe:
      initialDelaySeconds: 5
      periodSeconds: 2
      timeoutSeconds: 1
      successThreshold: 1
      failureThreshold: 3
```


## **Example Configurations**

### **1️) Deploy a Local MySQL Instance with Persistent Storage**
```yaml
general:
  db_local: true
  db_database: lightrunserver
  statefulset:
    enabled: true
    storageClassName: "gp2"
    storageSize: "100Gi"

```
### **2️) Deploy a Local MySQL Instance with Ephemeral Storage (Testing Mode)**
```yaml
general:
  db_local: true
  statefulset:
    enabled: false
  deployments:
    mysql:
      emptyDir:
        sizeLimit: 5Gi

```
### **3️) Connect to an External MySQL Instance**
```yaml
general:
  db_local: false
  db_endpoint: "mysql.external.example.com"
  db_database: lightrunserver
```
