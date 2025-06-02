# Monitoring and Alerting Guide for Lightrun Application

This guide highlights the key metrics that should be monitored for the Lightrun application when deployed on Kubernetes using a Helm chart. While it identifies the most critical metrics, it is the responsibility of customers to implement the monitoring using their preferred tools and to set up appropriate alerting mechanisms.

## 1. Bird's-eye View of System Health

**1.1 Nodes Status**
Monitor the overall health and performance of nodes within the Kubernetes cluster. Keep an eye on:

- CPU usage
- Memory utilization
- Disk space consumption

**1.2 Application URL Availability**
Ensure the main application URL is accessible and returns a successful HTTP status code (200).

## 2. Kubernetes Cluster Monitoring

**2.1 Deployment Status**
Monitor the status of deployments to ensure desired pods are running and replicating correctly.

**2.2 Pod Restart Count**
Track number of restarts per pod. Frequent restarts may indicate instability, errors or crashes.

**2.3 Kubernetes Events (Warning/Error)**
Monitor Kubernetes events to detect warnings or errors that may affect the cluster's stability:

- Track events with type "Warning" for potential issues like unhealthy containers or resource constraints.
- Monitor events with type "Error" for critical failures requiring immediate attention.

## 3. Resource Usage Monitoring

**3.1 Pod CPU Usage**
Track CPU usage across all pods. Sustained high CPU usage can signal bottlenecks or misconfigured resource limits.

**3.2 Pod Memory Resources**
Monitor memory usage across all pods to prevent out-of-memory issues and ensure optimal performance.

**3.3 Disk Space Consumption**
Monitor disk space consumption on nodes and persistent volumes to prevent storage exhaustion.

## 4. Network Monitoring

**4.1 Incoming Network Traffic (RX)**
Monitor incoming network data volume per pod to identify spikes or anomalies.

**4.2 Outgoing Network Traffic (TX)**
Track outgoing network data volume per pod to maintain proper network operation.

## 5. Ingress Monitoring

**5.1 Active Connections**
Monitor total active connections to ensure the application is able to handle incoming traffic effectively.

**5.2 Requests per Second**
Track request rates to ensure they are within acceptable limits and not causing performance issues.

**5.3 Rate-limited Requests (HTTP 429)**
Monitor requests that exceed rate limits. A high number of 429 responses may indicate misconfiguration or excessive load.

**5.4 Application Response Time**
Measure the response time of the main application endpoint to identify latency issues.

## 6. Lightrun Backend Application Metrics

The Lightrun backend exposes custom Prometheus metrics via the `/management/prometheus` endpoint. The following metrics can be monitored:

**6.1 Total Connected Agents per Runtime (`connected_agents_per_runtime`)**
Track the number of agents connected per runtime to ensure runtimes are reporting data correctly.

**6.2 JVM Memory Utilization (`jvm_memory_used_bytes`)**
Monitor JVM heap usage to prevent out-of-memory errors.

## 7. MySQL Database Monitoring

**7.1 CPU Utilization**
Monitor database CPU usage to ensure databases run efficiently without performance issues.

**7.2 RAM Utilization**
Track memory usage to avoid performance bottlenecks.

**7.3 Active DB Connections**
Monitor database connections to prevent overwhelming the database with simultaneous requests.

**7.4 File System Usage**
Track disk space usage on the database volume to prevent storage exhaustion.

**7.5 Network Throughput**
Monitor network traffic to and from MySQL.

**7.6 Query Latency**
Monitor query execution times to identify performance bottlenecks:

- Track average query execution time across all operations
- Identify slowest executing queries by type or table
- Track frequency of long-running queries (>500ms) that may indicate blocking issues

## 8. Redis Cache Monitoring

**8.1 CPU Utilization**
Observe CPU usage to ensure efficient processing of cache operations.

**8.2 RAM Utilization**
Track memory usage to avoid performance bottlenecks.

**8.3 Query Latency**
Monitor command execution times for cache operations:

- Track average response time for common commands (GET, SET, etc.)
- Monitor latency percentiles (p50, p95, p99) for different operation types
- Identify slowest executing commands that may indicate memory pressure or disk I/O issues
- Track frequency of delayed responses (>100ms) during high load periods

## 9. Backend HTTP Statistics

**9.1 HTTP Hits by Status Code**
Monitor the distribution of HTTP status codes returned by backend requests.

# Alerting Recommendations

Set up alerts based on the following conditions to enable proactive issue resolution:

- **Pod restart detected** – Any pod restarting more than once within a short period.
- **High CPU/Memory usage** - Sustained usage above 85% of capacity.
- **High Rate of 5xx Errors** - Indicative of backend failures or instability.
- **High number of rate-limited requests (429)** - May suggest malicious traffic or misconfigured clients.
- **Low disk space** - Trigger alerts when available disk space drops below a safe threshold.
- **Long application load time** - Detect latency issues impacting end-user experience.
- **Abnormal database connection counts** - May indicate overloading.
- **Network throughput anomalies** - Unexpected surges or drops in traffic could signal issues.

By monitoring the above metrics and setting up alerts accordingly, you can proactively manage your Lightrun application's performance and reliability in a Kubernetes environment.
