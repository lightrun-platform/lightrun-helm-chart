This section configures **Lightrun Router** with the **Openshift HAProxy Router**.
# Prerequisites
1. Ability to create a DNS A record that points to the Openshift HAProxy Router external record.
# Caution
If you want the Lightrun application to be accessible via the default OpenShift domain (disabled by default).   
For example, the application URL might look like this: https://lightrun.apps.test.o5mj.p1.openshiftapps.com/.  
Follow these steps:

1. Enable Default OpenShift Domain:   
In the values.yaml of the Lightrun Helm chart set the `general.openshift_embeded_hostname` parameter to `true`.

2. Set the lightrun_endpoint:  
In the values.yaml of the Lightrun Helm chart ensure that the `general.lightrun_endpoint` parameter is correctly set to match the desired OpenShift domain name.

3. Provide the Correct Certificate:   
In the values.yaml of the Lightrun Helm chart ensure that the `certificate` is correctly set to match the default OpenShift certificate. either by passing tls.crt and tls.ket directly in the values.yaml or point into existing cert:
    ```yaml
    certificate:
      existing_cert: ""
      tls:
        crt: ""
        key: ""
    ```
The default certificate for OpenShift is stored in a secret called router-certs in the openshift-config-managed namespace.
To retrieve this certificate, you will need admin permissions. Use the following command to extract the certificate:
```
kubectl get secrets -n openshift-config-managed router-certs -o yaml
```
For further details, refer to [the official OpenShift documentation on ingress certificates.](https://docs.openshift.com/container-platform/4.14/security/certificate_types_descriptions/ingress-certificates.html)
# Configure the Lightrun Router in the helm chart
Choose the most suitable option from the list below:  
[1 - Openshift HAProxy Router SSL <> Lightrun Router Non-SSL](#1---openshift-haproxy-router-ssl--lightrun-router-non-ssl)  
[2 - Openshift HAProxy Router Non-SSL <> Lightrun Router SSL](#2---openshift-haproxy-router-non-ssl--lightrun-router-ssl)  
##### 1 - Openshift HAProxy Router SSL <> Lightrun Router Non-SSL
  >The Openshift HAProxy Router listens for incoming requests on protocol/port HTTPS:443, performs SSL termination, and forwards the traffic to the Lightrun Router on protocol/port HTTP:8080 as a non-SSL connection.  
  >The Lightrun Router then directs the traffic to Lightrun services within the cluster.

In the "values.yaml" of the lightrun helm chart navigate to "general.router" and ensure at the minimum the following configuration is set:
* general.router.enabled: true
* general.router.tls.enabled: false
* general.router.ingress.enabled: true
* general.router.ingress.ingress_class_name: "openshift-default"
* general.router.ingress.annotations at the minimum have:
	* `haproxy.router.openshift.io/timeout: "90"`
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
    ingress_class_name: "openshift-default"  
    annotations:  
      haproxy.router.openshift.io/timeout: "90"  
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
##### 2 - Openshift HAProxy Router Non-SSL <> Lightrun Router SSL
>The Openshift HAProxy Router listen for incoming requests on protocol/port HTTPS:443 and passthrough unterminated SSL traffic to the Lightrun Router service on protocol/port HTTPS:8443.  
>The Lightrun Router then performs SSL termination and directs the traffic to Lightrun services within the cluster.
###### 2.1 - Create Openshift Route Custom Resource:
>We need to create an OpenShift Route resource instead of using an Ingress resource. According to the [OpenShift documentation on creating a route through an Ingress object](https://docs.openshift.com/container-platform/4.7/networking/routes/route-configuration.html#nw-ingress-creating-a-route-via-an-ingress_route-configuration), if you specify the passthrough value in the `route.openshift.io/termination` annotation, you must set the path to an empty string ('') and pathType to ImplementationSpecific in the Ingress specification. However, this requirement conflicts with the Lightrun router Ingress resource, which has path: / and pathType: Prefix.
* Replace `metadata.namespace` with your Lightrun's namespace installation.
* Replace `spec.host` with your lightrun endpoint FQDN.
* Replace `spec.to.name` with the service name of the lightrun router
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  namespace: lightrun-tig
  name: lightrun-route-passthrough-secured
spec:
  host: lightrun-tig-router-oc.internal.lightrun.com
  port:
    targetPort: 8443
  tls:
    termination: passthrough
    insecureEdgeTerminationPolicy: None
  to:
    kind: Service
    name: lightrun-router
```
###### 2.2 - Configure the Lightrun Router in the Helm chart
In the "values.yaml" of the lightrun helm chart navigate to "general.router" and ensure at the minimum the following configuration is set:
* general.router.enabled: true
* general.router.tls.enabled: true
* general.router.ingress.enabled: false
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

1.  fetch the external-ip of the Openshift HAProxy Router service by running - `  kubectl get services <openshift router service name> -n <openshift-ingress-namspace> for example: 
	```
	NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP                                                                     PORT(S)                      AGE
	router-default            LoadBalancer   172.30.64.160   internal-xxxxxx-1542719919.us-east-1.elb.amazonaws.com                          80:30548/TCP,443:31340/TCP   7h23m
	```
	   If you don't see an EXTERNAL-IP, it may be because the Openshift HAProxy Router couldn't configure the Load Balancer.  
	   To investigate further, you can inspect the logs and events of the Openshift HAProxy Router.

2. Based on your DNS provider, create a DNS A record with the record name matching the lightrun endpoint (e.g., "lightrun-tig-router-oc.internal.lightrun.com") and set it to the EXTERNAL-IP provided in the output (e.g., "internal-xxxxxx-1542719919.us-east-1.elb.amazonaws.com").

# Verification
## Verify Lightrun Router get requests from OpenShift HAProxy Router:

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