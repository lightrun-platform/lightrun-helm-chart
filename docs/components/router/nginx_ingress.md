This section configures **Lightrun Router** with the **Nginx Ingress Controller**.
# Prerequisites
1. Ability to create a DNS A record that points to the Nginx external record.
2. [Nginx ingress controller installed](https://kubernetes.github.io/ingress-nginx/deploy/) in the cluster.
# Configure the Lightrun Router in the helm chart
Choose the most suitable option from the list below:  
[1 - Nginx  SSL <> Lightrun Router SSL](#1---nginx--ssl--lightrun-router-ssl)  
[2 - Nginx SSL <> Lightrun Router Non-SSL](#2---nginx-ssl--lightrun-router-non-ssl)
##### 1 - Nginx  SSL <> Lightrun Router SSL
   >The Nginx listens for incoming requests on protocol/port HTTPS:443, performs SSL termination, and forwards the traffic to the Lightrun Router on protocol/port HTTPS:8443.  
   >The Lightrun Router then performs SSL termination and directs the traffic to Lightrun services within the cluster.

In the "values.yaml" of the lightrun helm chart navigate to "general.router" and ensure at the minimum the following configuration is set:
* general.router.enabled: true
* general.router.tls.enabled: true
* general.router.ingress.enabled: true
* general.router.ingress.ingress_class_name: "nginx"
* general.router.ingress.annotations at the minimum have:
	* `nginx.ingress.kubernetes.io/proxy-read-timeout: "90"`
	* `nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"`
	* `nginx.ingress.kubernetes.io/proxy-body-size: "25m"`
    * `nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"`
* general.router.service.enabled: true
* general.router.service.type: ClusterIP
* general.router.host_port.enabled: false  

As shown in the following example:
```yaml
router:  
  ## general.router.enabled - boolean flag, indicates whether to enable a Router (single entrypoint for Lightrun deployment).  
  enabled: true  
  
  tls:
    enabled: true

  ingress:  
    enabled: true  
    ingress_class_name: "nginx"  
    annotations:  
      nginx.ingress.kubernetes.io/proxy-read-timeout: "90"  
      nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"  
      nginx.ingress.kubernetes.io/proxy-body-size: "25m"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    labels: {}  
  
  service:  
    enabled: true  
    ## Supported types: ClusterIP, LoadBalancer, NodePort, Headless  
    type: "ClusterIP"  
    annotations: {}  
    labels: {}  
    ports:  
      http: 8080  
      https: 443  
  
  ## Only relevant for single-vm use case  
  host_port:  
    # Required to set general.router.tls.enabled to true  
    enabled: false  
    ports:  
      http: 80  
      https: 443
```
##### 2 - Nginx SSL <> Lightrun Router Non-SSL
  >The Nginx listens for incoming requests on protocol/port HTTPS:443, performs SSL termination, and forwards the traffic to the Lightrun Router on protocol/port HTTP:8080 as a non-SSL connection.  
  >The Lightrun Router then directs the traffic to Lightrun services within the cluster.

In the "values.yaml" of the lightrun helm chart navigate to "general.router" and ensure at the minimum the following configuration is set:
* general.router.enabled: true
* general.router.tls.enabled: false
* general.router.ingress.enabled: true
* general.router.ingress.ingress_class_name: "nginx"
* general.router.ingress.annotations at the minimum have:
	* `nginx.ingress.kubernetes.io/proxy-read-timeout: "90"`
	* `nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"`
	* `nginx.ingress.kubernetes.io/proxy-body-size: "25m"`
* general.router.service.enabled: true
* general.router.service.type: ClusterIP
* general.router.host_port.enabled: false  

As shown in the following example:
```yaml
router:  
  ## general.router.enabled - boolean flag, indicates whether to enable a Router (single entrypoint for Lightrun deployment).  
  enabled: true  
  
  tls:
    enabled: false

  ingress:  
    enabled: true  
    ingress_class_name: "nginx"  
    annotations:  
      nginx.ingress.kubernetes.io/proxy-read-timeout: "90"  
      nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"  
      nginx.ingress.kubernetes.io/proxy-body-size: "25m"  
    labels: {}  
  
  service:  
    enabled: true  
    ## Supported types: ClusterIP, LoadBalancer, NodePort, Headless  
    type: "ClusterIP"  
    annotations: {}  
    labels: {}  
    ports:  
      http: 8080  
      https: 443  
  
  ## Only relevant for single-vm use case  
  host_port:  
    # Required to set general.router.tls.enabled to true  
    enabled: false  
    ports:  
      http: 80  
      https: 443
```

# Create a DNS record pointing to Nginx address

1.  fetch the external-ip of the nginx ingress controller service by running - `  kubectl get services <ingress-nginx-controller service name> -n <namspace> for example: 
	```
	NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP                                                                        PORT(S)                                     AGE
	ingress-nginx-controller   LoadBalancer   172.20.200.93   internal-xxxxxx-1542719919.us-east-1.elb.amazonaws.com   80:32679/TCP,443:30997/TCP,2003:32029/TCP   247d
	```
 
	   If you don't see an EXTERNAL-IP, it may be because the Nginx Ingress Controller couldn't configure the Load Balancer on hosted cloud provider.  
	   To investigate further, you can inspect the logs and events of the Nginx Ingress Controller.

2. Based on your DNS provider, create a DNS A record with the record name matching the lightrun endpoint (e.g., "lightrun-tig-router-nginx.internal.lightrun.com") and set it to the EXTERNAL-IP provided in the output (e.g., "internal-xxxxxx-1542719919.us-east-1.elb.amazonaws.com").

# Verification
## Verify Lightrun Router get requests from Nginx Ingress Controller:

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