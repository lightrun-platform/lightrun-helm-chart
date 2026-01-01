This section configures **Lightrun Router** the **GKE  Service Controller**.
This guide covers set either  [External Network Load Balancer](https://cloud.google.com/load-balancing/docs/tcp) or [Internal Network Load Balancer](https://cloud.google.com/load-balancing/docs/tcp/internal-proxy) based on Kubernetes [Service resources](https://kubernetes.io/docs/concepts/services-networking/service/).
# Prerequisites
1. Ability to create DNS A record points to the GCP Network Load Balancer record.
# Configure the Lightrun Router in the helm chart

##### GCP Network Load Balancer  Non-SSL <> Lightrun Router SSL
   >The GCP Network Load Balancer listens for incoming requests on protocol/port TCP:443 and forwards traffic to the Lightrun router on protocol/port HTTPS:8443.
   >The Lightrun router then performs SSL termination and directs the traffic to Lightrun services within the cluster.

In the "values.yaml" of the lightrun helm chart navigate to "general.router" and ensure at the minimum the following configuration is set:
* general.router.enabled: true
* general.router.tls.enabled: true
* general.router.ingress.enabled: false
* general.router.ingress.ingress_class_name: ""
* general.router.service.enabled: true
* general.router.service.type: LoadBalancer
* general.router.host_port.enabled: false  

As shown in the following example:
```yaml
router:  
  ## general.router.enabled - boolean flag, indicates whether to enable a Router (single entrypoint for Lightrun deployment).  
  enabled: true  
  tls:  
    # If enabled router will expose HTTPS traffic  
    # If internal_tls.enabled is set to true, SSL termination will be enabled regardless of this value    # Has to be enabled when exposed by the host_port
    enabled: true  
  
  ingress:  
    enabled: false  
    ingress_class_name: ""  
    # If your ingress limiting the body size, you can override it with annotation  
    # example for nginx-ingress: "nginx.ingress.kubernetes.io/proxy-body-size": "50m"
    annotations: {}
    labels: {}  
  
  service:  
    enabled: true  
    ## Supported types: ClusterIP, LoadBalancer, NodePort, Headless  
    type: "LoadBalancer"  
    annotations: {}  
    labels: {}  
    ports:  
      http: 8080  
      https: 8443  
  
  ## Only relevant for single-vm use case  
  host_port:  
    # Required to set general.router.tls.enabled to true  
    enabled: false  
    ports:  
      http: 80  
      https: 443
```
The above sample will create External Network Load Balancer, if instead you want to use Internal Network load balancer please add `networking.gke.io/load-balancer-type: "Internal"` annotation into general.router.service.annotations 
# Create a DNS record pointing to GCP Network Load Balancer 

1. fetch the GCP Network Load Balancer external-ip of the lightrun router service by running - ` kubectl get service -n <lightrun_namespace>` for example: 
	```
    NAME                                                  TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                        AGE
    lightrun-tig-router-gcp-3-6-5-tls-backend             ClusterIP      10.16.14.223   <none>           8080/TCP                       106m
    lightrun-tig-router-gcp-3-6-5-tls-frontend            ClusterIP      10.16.14.206   <none>           8080/TCP                       106m
    lightrun-tig-router-gcp-3-6-5-tls-keycloak            ClusterIP      10.16.14.72    <none>           8080/TCP                       106m
    lightrun-tig-router-gcp-3-6-5-tls-keycloak-headless   ClusterIP      None           <none>           7800/TCP                       106m
    lightrun-tig-router-gcp-3-6-5-tls-mysql               ClusterIP      None           <none>           3306/TCP                       106m
    lightrun-tig-router-gcp-3-6-5-tls-redis               ClusterIP      None           <none>           6379/TCP                       106m
    lightrun-tig-router-gcp-3-6-5-tls-router              LoadBalancer   10.16.14.60    35.198.185.248   443:30540/TCP,8080:32346/TCP   106m
    ```
    In the output above, the relevant service is "lightrun-tig-router-gcp-3-6-5-tls-router," which is of type LoadBalancer.  
    If the EXTERNAL-IP is not displayed, it may be due to the Kubernetes Service Controller being unable to configure the Load Balancer on GCP.
    To further investigate, you can check the events related to the lightrun router service object.


2. Based on your DNS provider, create a DNS A record with the record name matching the lightrun endpoint(e.g., "lightrun-tig-router-gcp-tls.internal.lightrun.com") and set it to the EXTERNAL-IP provided in the output (e.g., "35.198.185.248").


# Verification
## Verify Lightrun Router get requests from GCP Network Load Balancer:

1. Run `kubectl get pods -n <lightrun_namespace>` and fetch the name lightrun router pod.
	```
	lightrun-tig-backend-8b7d546d7-7n2nc     1/1     Running   0          85m
	lightrun-tig-frontend-574b8f7b74-nf6ps   1/1     Running   0          85m
	lightrun-tig-keycloak-79bb8d9686-zb87z   1/1     Running   0          85m
	lightrun-tig-mysql-0                     1/1     Running   0          85m
	lightrun-tig-redis-9cb6877-49vpt         1/1     Running   0          85m
	lightrun-tig-router-65cb8ddf58-slsxn     1/1     Running   0          85m
	
	```

2. Run `kubectl logs <name of the router pod from point 1 above> -n <lightrun_namespace>` and confirm that requests are seen after you tried to access the lightrun server. for instance:
	```
	x.x.x.x - - [07/Aug/2024:15:03:18 +0000] "GET /content/geomanist-regular-OKFSMC6R.woff2 HTTP/1.1" 200 28420 "https://lightrun-tig-router-nginx.internal.lightrun.com/app/main.bundle.css" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" "x.x.x.x"
	x.x.x.x - - [07/Aug/2024:15:03:18 +0000] "GET /api/company/a8dcd0b3-2994-48d5-b6a0-954be6c98d92/agent-pools/default HTTP/1.1" 200 313 "https://lightrun-tig-router-nginx.internal.lightrun.com/company/a8dcd0b3-2994-48d5-b6a0-954be6c98d92" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" "x.x.x.x"
	x.x.x.x - - [07/Aug/2024:15:03:18 +0000] "GET /web/company/a8dcd0b3-2994-48d5-b6a0-954be6c98d92/1.38/onboardingStatus HTTP/1.1" 200 165 "https://lightrun-tig-router-nginx.internal.lightrun.com/company/a8dcd0b3-2994-48d5-b6a0-954be6c98d92" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" "x.x.x.x"
	x.x.x.x - - [07/Aug/2024:15:03:18 +0000] "GET /web/company/a8dcd0b3-2994-48d5-b6a0-954be6c98d92/1.38/onboardingStatus HTTP/1.1" 200 160 "https://lightrun-tig-router-nginx.internal.lightrun.com/company/a8dcd0b3-2994-48d5-b6a0-954be6c98d92" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" "x.x.x.x"
	x.x.x.x - - [07/Aug/2024:15:03:18 +0000] "GET /web/company/a8dcd0b3-2994-48d5-b6a0-954be6c98d92/1.38/onboardingStatus HTTP/1.1" 200 165 "https://lightrun-tig-router-nginx.internal.lightrun.com/company/a8dcd0b3-2994-48d5-b6a0-954be6c98d92" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" "x.x.x.x"
	```

3. On GCP console check the Network Load Balancer status:  
![gcp-network-load-balancer-details](../../images/gcp-network-load-balancer-details.png)