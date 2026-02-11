# Expose Deployment via NodePort

The deployment `web-app` (running nginx) needs to be accessible from outside the cluster.

1. Expose the deployment named `web-app` as a Service named `web-service`.
2. The Service type must be `NodePort`.
3. The NodePort must be exactly `30080`.
4. The service port should be `80`.
