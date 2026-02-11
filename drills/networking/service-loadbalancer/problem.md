# LoadBalancer Service Exposure

An Nginx application needs to be accessible outside the cluster using a specific IP address layout provided by MetalLB.

Requirements:

- create a deployment `lb-app` using image `nginx:alpine` in namespace `public`
- Expose this deployment using a Service named `lb-service`
- The Service must be of type `LoadBalancer`
- Verify that the Service receives an External IP address (allocated by MetalLB)
- (Optional) Verify connectivity to the External IP

Current state: Namespace `public` may not exist. MetalLB is configured in the cluster.
