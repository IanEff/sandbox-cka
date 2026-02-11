# NodePort Exposure

You need to expose an application externally using NodePort.

1. Create a Deployment named `api-gateway` with 3 replicas using image `nginx:1-alpine` in Namespace `external-apps`
2. Create a Service named `api-gateway-svc` of type ClusterIP on port 80
3. Verify the Service works internally by creating a test Pod and curling the Service (self-check)
4. Now convert the Service to `NodePort` type using `kubectl patch` (or edit/apply)
5. Write the NodePort assigned to `/opt/course/overlay5/nodeport.txt`
6. On a node, verify that kube-proxy is listening on that port using `ss -nlp | grep <NODEPORT>` (or netstat) and write the output line to `/opt/course/overlay5/listening-port.txt`
7. Test connectivity by curling `localhost:<NODEPORT>` from the node itself.
8. Write a curl command that would work from outside the cluster into `/opt/course/overlay5/external-curl.sh` (assume node IP is `192.168.56.10` or the IP of your node).

**Verification**: The Service should be accessible on the NodePort from any node in the cluster.
