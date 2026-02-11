# Drill: Label Mismatch

A Deployment named `updater` and a Service named `updater-service` are running in the `default` namespace.
However, `kubectl get endpoints updater-service` shows no endpoints.

**Task:**
Troubleshoot the issue and fix the configuration so that `updater-service` correctly routes traffic to the `updater` Pods.

**Requirements:**
- Do not delete the Deployment.
- Do not delete the Service (edit it in place).
- The Service must target the Pods created by the `updater` Deployment.
