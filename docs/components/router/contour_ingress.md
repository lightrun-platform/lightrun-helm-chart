This section configures **Lightrun Router** with the **Contour Ingress Controller**.
This guide covers set [Contour Ingress Controller](https://projectcontour.io/docs/main/) with [Contour HTTPProxy](https://projectcontour.io/docs/main/config/fundamentals/) that points to Lightrun Router Kubernetes service.
# Prerequisites
1. Ability to create a DNS A record that points to the Contour Ingress Controller external address.
2. [Contour Ingress Controller installed](https://projectcontour.io/getting-started/) in the cluster.

# Caution
While Contour have [Ingress V1 Support](https://projectcontour.io/docs/1.30/config/ingress/) we can not use this option because of websocket support which seems to be available only on HTTPProxy
# Configure the Contour Ingress Controller and HTTPProxy with the Lightrun Router 
Choose the most suitable option from the list below:  
[1 - Contour Ingress Controller SSL <> Lightrun Router SSL](#1-contour-ingress-controller-ssl-lightrun-router-ssl)  
[2 - Contour Ingress Controller SSL <> Lightrun Router Non-SSL](#2-contour-ingress-controller-ssl-lightrun-router-non-ssl)
#### 1 - Contour Ingress Controller SSL <> Lightrun Router SSL
>Contour Ingress Controller listens on protocol/port HTTPS:443 for incoming requests, performs SSL termination,  and forwards traffic to the Lightrun router on protocol/port HTTPS:8443.  
>The Lightrun router then performs SSL termination and forwards traffic to Lightrun services inside the cluster.
##### 1.1 - Create Contour HTTPProxy Custom Resource
* Replace `metadata.namespace` with your Lightrun's namespace installation.
* Replace `spec.virtualhost.fqdn` with your Lightrun endpoint FQDN.
* Replace `spec.virtualhost.tls.secretName` with your secret name that include lighrun certificate , if it was installed as part of lightrun helm chart you may find it using command `kubectl get secrets -n lightrun`.
* Replace `spec.virtualhost.routes.services[].name` with the service name of the lightrun router

```yaml
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: lightrun-router
  namespace: lightrun-tig
spec:
  virtualhost:
    fqdn: lightrun-tig-router-contour.internal.lightrun.com
    tls:
      secretName: lightrun-tig-certificate
  routes:
    - conditions:
        - prefix: /
      services:
        - name: lightrun-router
          port: 8443
          protocol: tls
      enableWebsockets: true
      timeoutPolicy:
        request: 600s      # Timeout for the entire request
        idle: 600s         # Timeout for idle connections
        response: 600s     # Timeout for waiting on a response from the backend
```


##### 1.2 - Configure the Lightrun Router in the Helm chart
In the "values.yaml" of the Lightrun Helm chart navigate to "general.router" and ensure at the minimum the following configuration is set:
* general.router.enabled: true
* general.router.tls.enabled: true
* general.router.ingress.enabled: false
* general.router.service.enabled: true
* general.router.service.ports.https: 8443
* general.router.service.type: ClusterIP
* general.router.host_port.enabled: false  
```yaml
router:  
  ## general.router.enabled - boolean flag, indicates whether to enable a Router (single entrypoint for Lightrun deployment).  
  enabled: true  
  
  tls:
    enabled: true

  ingress:  
    enabled: false  
    ingress_class_name: ""  
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
  
  ## Only relevant for single-vm use case  
  host_port:  
    # Required to set general.router.tls.enabled to true  
    enabled: false  
    ports:  
      http: 80  
      https: 443
```
#### 2 - Contour Ingress Controller SSL <> Lightrun Router Non-SSL
  >The Contour Ingress Controller SSL listens for incoming requests on protocol/port HTTPS:443, performs SSL termination, and forwards the traffic to the Lightrun Router on protocol/port HTTP:8080 as a non-SSL connection.  
  >The Lightrun Router then directs the traffic to Lightrun services within the cluster.
##### 2.1 - Create Contour Ingress Controller Custom Resource
* Replace `metadata.namespace` with your Lightrun's namespace installation.
* Replace `spec.virtualhost.fqdn` with your Lightrun endpoint FQDN.
* Replace `spec.virtualhost.tls.secretName` with your secret name that include lighrun certificate , if it was installed as part of lightrun helm chart you may find it using command kubectl get secrets -n lightrun.
* Replace `spec.virtualhost.routes.services[].name` with the service name of the lightrun router

```yaml
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: lightrun-router
  namespace: lightrun-tig
spec:
  virtualhost:
    fqdn: lightrun-tig-router-contour.internal.lightrun.com
    tls:
      secretName: lightrun-tig-certificate
  routes:
    - conditions:
        - prefix: /
      services:
        - name: lightrun-router
      port: 8080
      enableWebsockets: true
      timeoutPolicy:
        request: 600s      # Timeout for the entire request
        idle: 600s         # Timeout for idle connections
        response: 600s     # Timeout for waiting on a response from the backend
```
##### 2.2 - Configure the Lightrun Router in the Helm chart
In the "values.yaml" of the lightrun Helm chart navigate to "general.router" and ensure at the minimum the following configuration is set:
* general.router.enabled: true
* general.router.tls.enabled: false
* general.router.ingress.enabled: false
* general.router.service.enabled: true
* general.router.service.type: ClusterIP
* general.router.service.ports.http: 8080
* general.router.host_port.enabled: false  

As shown in the following example:
```yaml
router:  
  ## general.router.enabled - boolean flag, indicates whether to enable a Router (single entrypoint for Lightrun deployment).  
  enabled: true  
  
  tls:
    enabled: false

  ingress:  
    enabled: false  
    ingress_class_name: ""  
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
  
  ## Only relevant for single-vm use case  
  host_port:  
    # Required to set general.router.tls.enabled to true  
    enabled: false  
    ports:  
      http: 80  
      https: 443
```
#### 3 - Contour Ingress Controller Non-SSL <> Lightrun Router SSL
>The Contour Ingress Controller listen for incoming requests on protocol/port HTTPS:443 and passthrough unterminated SSL traffic to the Lightrun Router service on protocol/port HTTPS:8443.  
>The Lightrun Router then performs SSL termination and directs the traffic to Lightrun services within the cluster.
##### 3.1 - Create Contour HTTPProxy Custom Resource
* Replace `metadata.namespace` with your Lightrun's namespace installation.
* Replace `spec.virtualhost.fqdn` with your Lightrun endpoint FQDN.
* Replace `spec.virtualhost.tls.passthrough` set to `true`.
* Replace `spec.virtualhost.tcpproxy.services[].name` with the service name of the lightrun router
```yaml
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: lightrun-router
  namespace: lightrun-tig
spec:
  virtualhost:
    fqdn: lightrun-tig-router-contour.internal.lightrun.com
    tls:
      passthrough: true
  tcpproxy:
    services:
      - name: lightrun-router
        port: 8443
```


##### 3.2 - Configure the Lightrun Router in the Helm chart
In the "values.yaml" of the Lightrun Helm chart navigate to "general.router" and ensure at the minimum the following configuration is set:
* general.router.enabled: true
* general.router.tls.enabled: true
* general.router.ingress.enabled: false
* general.router.service.enabled: true
* general.router.service.ports.https: 8443
* general.router.service.type: ClusterIP
* general.router.host_port.enabled: false
```yaml
router:  
  ## general.router.enabled - boolean flag, indicates whether to enable a Router (single entrypoint for Lightrun deployment).  
  enabled: true  
  
  tls:
    enabled: true

  ingress:  
    enabled: false  
    ingress_class_name: ""  
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
  
  ## Only relevant for single-vm use case  
  host_port:  
    # Required to set general.router.tls.enabled to true  
    enabled: false  
    ports:  
      http: 80  
      https: 443
```

# Create a DNS record pointing to Contour Ingress Controller address

1.  Fetch the external-ip of the Contour Ingress Controller service by running - `  kubectl get services <contour-ingress-controller service name> -n <contour-ingress-controller> for example: 
	```
	NAME            	TYPE           CLUSTER-IP      EXTERNAL-IP    																   PORT(S)                      AGE
	contour-tig-envoy   LoadBalancer   172.20.103.33   k8s-projectc-contourt-295d652406-ae0730f2fb54e13e.elb.us-east-1.amazonaws.com   80:32146/TCP,443:30336/TCP   127m	
 	```

2. Based on your DNS provider, create a DNS A record with the record name matching the Lightrun endpoint (e.g., "lightrun-tig-router-contour.internal.lightrun.com") and set it to the EXTERNAL-IP provided in the output (e.g., "k8s-projectc-contourt-295d652406-ae0730f2fb54e13e.elb.us-east-1.amazonaws.com").

# Verification
## Verify Lightrun Router get requests from nginx ingress contoller:

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