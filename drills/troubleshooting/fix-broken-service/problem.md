# Fix Broken Service

The service `web-access` failing to route traffic to the application.

## Requirements

1. Investigate the Service `web-access` and Deployment `web-app` in namespace `debug-drill`.
2. Fix the configuration so that `curl http://web-access` works (from within the cluster).
3. Do not delete the Service or Deployment, update them in place.
