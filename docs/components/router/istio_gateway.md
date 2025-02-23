This section configures **Lightrun Router** the **Istio Gateway**.
This guide covers set [Isito Gateway](https://istio.io/latest/docs/reference/config/networking/gateway/) with [Isito Virtual Service](https://istio.io/latest/docs/reference/config/networking/virtual-service/) that points to Lightrun Router Kubernetes service.
# Prerequisites
1. Ability to create a DNS A record that points to the Istio gateway external address.
2. [Istio installed](https://istio.io/latest/docs/setup/install/) in the cluster. including [Istio Ingress Gateway](https://istio.io/latest/docs/setup/additional-setup/gateway/#deploying-a-gateway).
# Configure the Istio Gateway and Virtual Service with the Lightrun Router 
Choose the most suitable option from the list below:  
[1 - Istio Gateway Non-SSL <> Lightrun Router SSL](#1---istio-gateway--non-ssl--lightrun-router-ssl)  
[2 - Istio Gateway SSL <> Lightrun Router Non-SSL](#2---istio-gateway--ssl--lightrun-router-non-ssl)
##### 1 - Istio Gateway  Non-SSL <> Lightrun Router SSL
   >The Istio Gateway listen for incoming requests on protocol/port HTTPS:443 and passthrough unterminated SSL traffic to the Lightrun Router service on protocol/port HTTPS:8443.  
   >The Lightrun Router then performs SSL termination and directs the traffic to Lightrun services within the cluster.
###### 1.1 - Create an Istio Gateway Custom Resource
* Replace `spec.servers[0].hosts` with your Lightrun endpoint FQDN.
* Make sure `spec.servers[0].tls.mode` is set to `PASSTHROUGH`, otherwise you might run into the [gateway missmatch issue](https://istio.io/latest/docs/ops/common-problems/network-issues/#gateway-mismatch).
```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: lightrun-gateway
spec:
  # The selector matches the ingress gateway pod labels.
  # If you installed Istio using Helm following the standard documentation, this would be "istio=ingress"
  selector:
    istio: ingress
  servers:
    - port:
        number: 443
        name: https
        protocol: HTTPS
      hosts:
        - "lightrun-tig-router-istio.internal.lightrun.com"
      tls:
        mode: PASSTHROUGH
```
###### 1.2 - Create an Istio Virtual Service Custom Resource
* Replace `spec.hosts[0]` with your lightrun endpoint FQDN.
* Replace `spec.tls[0].match[0].sniHosts` with your lightrun endpoint FQDN.
* Replace `spec.tls[0].route[0].destination.host` with `<lightrun router service name>.<lightrun namepsace>.svc.cluster.local` (Replace `svc.cluster.local` if you are using a non-default Kubernetes internal DNS domain).
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: lightrun-virtual-service
spec:
  hosts:
    - "lightrun-tig-router-istio.internal.lightrun.com"
  gateways:
    - lightrun-gateway
  tls:
    - match:
        - port: 443
          sniHosts:
            - "lightrun-tig-router-istio.internal.lightrun.com"
      route:
        - destination:
            host: lightrun-tig-router.lightrun-tig.svc.cluster.local
            port:
              number: 8443
```
###### 1.3 - Configure the Lightrun Router in the Helm chart
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
##### 2 - Istio Gateway  SSL <> Lightrun Router Non-SSL
  >The Istio Gateway listens for incoming requests on protocol/port HTTPS:443, performs SSL termination, and forwards the traffic to the Lightrun Router on protocol/port HTTP:8080 as a non-SSL connection.  
  >The Lightrun Router then directs the traffic to Lightrun services within the cluster.
###### 2.1 - Copy the Lightrun endpoint certificate as a secret into the Istio Ingress Gateway's namespace

The certificate must be located in the same namespace where the Istio Ingress Gateway is deployed. Please note that you will need to manually add the certificate as a secret within the Istio Ingress Gateway namespace. You can refer to the following procedure for creating that secret using the kubectl create secret command:
```shell
echo "<base64-encoded-key>" | base64 --decode > lightrun-tls.key
echo "<base64-encoded-cert>" | base64 --decode > lightrun-tls.crt
kubectl create secret tls lightrun-certificate --cert=lightrun-tls.crt --key=lightrun-tls.key - n <istio-ingress-gateway-namespace>
```
Ensure that you replace <istio-ingress-gateway-namespace> with the actual namespace of the Istio Ingress Gateway. You can find the <base64-encoded-key> in the values.yaml file of the Lightrun Helm chart under certificate.tls.key, and the <base64-encoded-cert> under certificate.tls.crt, assuming the certificate is provisioned this way in the Lightrun Helm chart. Alternatively, you can use any method of your choice to create that secret.
###### 2.2 - Create an Istio Gateway Custom Resource
* Replace `spec.servers[0].hosts` with your lightrun endpoint FQDN
* Make sure `spec.servers[0].tls.mode` is set to `SIMPLE`, otherwise you might run into the [gateway with tls passthrough issue](https://istio.io/latest/docs/ops/common-problems/network-issues/#gateway-with-tls-passthrough)
* Make sure `spec.servers[0].tls.credentialName` matches the created secret of the previous step.
```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: lightrun-gateway
spec:
  # The selector matches the ingress gateway pod labels.
  # If you installed Istio using Helm following the standard documentation, this would be "istio=ingress"
  selector:
    istio: ingress
  servers:
    - port:
        number: 443
        name: https
        protocol: HTTPS
      hosts:
        - "lightrun-tig-router-istio.internal.lightrun.com"
      tls:
        mode: SIMPLE
        credentialName: lightrun-certificate #secret has to be in the same namespace as the Istio Gateway pod
```
###### 2.3 - Create an Istio Virtual Service Custom Resource
* Replace `spec.hosts[0]` with your lightrun endpoint FQDN
* Replace `spec.http[0].route[0].destination.host` with `<lightrun router service name>.<lightrun namepsace>.svc.cluster.local` (replace svc.cluster.local if you are not using the default k8s internal DNS domain)
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: lightrun-virtual-service
spec:
  hosts:
    - "lightrun-tig-router-istio.internal.lightrun.com"
  gateways:
    - lightrun-gateway
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: lightrun-tig-router.lightrun-tig.svc.cluster.local
            port:
              number: 8080
```
###### 2.4 - Configure the Lightrun Router in the Helm chart
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

# Create a DNS record pointing to Istio Ingress Gateway address

1.  Fetch the external-ip of the Istio Ingress Gateway service by running - `  kubectl get services <istio-ingress-gateway service name> -n <istio-ingress-gateway-namspace> for example: 
	```
	NAME            TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                      AGE
	istio-ingress   LoadBalancer   10.43.224.255   192.168.64.2   15021:32465/TCP,80:30116/TCP,443:32124/TCP   5h31m 
	```

2. Based on your DNS provider, create a DNS A record with the record name matching the Lightrun endpoint (e.g., "lightrun-tig-router-istio.internal.lightrun.com") and set it to the EXTERNAL-IP provided in the output (e.g., "192.168.64.2").

# Verification
## Verify istio installation is ok:
> you will need [istioctl installed](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/) in order to do the following commands

1. Run `istioctl analyze -n <lightrun-namespace>` and verify there are no errors. as shown in the following exmaple:
	```shell
	istioctl analyze -n lightrun-tig
	Info [IST0102] (Namespace lightrun-tig) The namespace is not enabled for Istio injection. Run 'kubectl label namespace lightrun-tig istio-injection=enabled' to enable it, or 'kubectl label namespace lightrun-tig istio-injection=disabled' to explicitly mark it as not needing injection.
	Info [IST0118] (Service lightrun-tig/lightrun-tig-keycloak-headless) Port name kc-cluster (port: 7800, targetPort: 7800) doesn't follow the naming convention of Istio port.
	Info [IST0118] (Service lightrun-tig/lightrun-tig-keycloak) Port name keycloak (port: 8080, targetPort: 9080) doesn't follow the naming convention of Istio port.
	```
	you can see, the analyzer reported no errors. The info messages can be ignored. Potential errors that the analyzer might report include:
   - Certificate not found:
 	 >   Error [IST0101] (Gateway lightrun-tig/lightrun-gateway) Referenced credentialName not found: "lightrun-where-is-my-certificate"
   - Route destination port not found:
	  >   Error [IST0101] (VirtualService lightrun-tig/lightrun-virtual-service) Referenced host:port not found: "lightrun-tig-router.lightrun-tig.svc.cluster.local:5555"
   - Route destination host not found:
	  >   Error [IST0101] (VirtualService lightrun-tig/lightrun-virtual-service) Referenced host not found: "lightrun-tig-router.lightrun-tig.svc.cluster.local.incorrect"
   - Referenced gateway not found:
	  >   Error [IST0101] (VirtualService lightrun-tig/lightrun-virtual-service) Referenced gateway not found: "lightrun-gateway-incorrect"

2. Run `istioctl proxy-config listener -n <istio-ingress-namespace> <istio-ingress-deployment>` to retrieve information about listener configuration.

	Example of good output of [1 - Istio Gateway Non-SSL <> Lightrun Router SSL](#1---istio-gateway--non-ssl--lightrun-router-ssl) use case:
	```shell
	istioctl proxy-config listener -n istio-ingress istio-ingress-69598f76d8-l5df6
	ADDRESSES PORT  MATCH                                                DESTINATION
	0.0.0.0   443   SNI: lightrun-tig-router-istio.internal.lightrun.com Cluster: outbound|8443||lightrun-tig-router.lightrun-tig.svc.cluster.local
	```

	Example of good output of [2 - Istio Gateway  SSL <> Lightrun Router Non-SSL](#2---istio-gateway--ssl--lightrun-router-non-ssl) use case:
	```shell
	istioctl proxy-config listener -n istio-ingress istio-ingress-69598f76d8-l5df6
	ADDRESSES PORT  MATCH                                                DESTINATION
	0.0.0.0   443   SNI: lightrun-tig-router-istio.internal.lightrun.com Route: https.443.https.lightrun-gateway.lightrun-tig
	```
3. (Only relevant to [2 - Istio Gateway  SSL <> Lightrun Router Non-SSL](#2---istio-gateway--ssl--lightrun-router-non-ssl)) Run `istioctl proxy-config route -n <istio-ingress-namespace> <istio-ingress-deployment>` in order to retrieve information about route configuration.

	Example of good output:
	```shell
	istioctl proxy-config route -n istio-ingress istio-ingress-69598f76d8-l5df6
	NAME                                              VHOST NAME                                              DOMAINS                                             MATCH                  VIRTUAL SERVICE
	https.443.https.lightrun-gateway.lightrun-tig     lightrun-tig-router-istio.internal.lightrun.com:443     lightrun-tig-router-istio.internal.lightrun.com     /*                     lightrun-virtual-service.lightrun-tig
	```
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