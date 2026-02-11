# Troubleshooting Service Selectors

In namespace `debug-svc`:

1. There is a Deployment `frontend` (3 replicas) and a Service `frontend-svc`.
2. Users report connection refused when trying to reach the Service.
3. Investigate the Service and Deployment configuration.
4. Fix the issue so that `frontend-svc` correctly routes traffic to the `frontend` pods.

(Do not recreate the Deployment, only fix the Service).
