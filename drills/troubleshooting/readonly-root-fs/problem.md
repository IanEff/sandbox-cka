# Drill: Read-Only Root Filesystem

## Scenario

The pod `web-logger` in namespace `default` is failing to start. It requires a writable location for its logs at `/var/log/app.log`.

## Task

1. Diagnose why the pod is failing.
2. Fix the pod configuration so that the application can successfully write to `/var/log/app.log`.
   - **Constraint**: You must maintain the security posture where the root filesystem remains read-only.
   - **Hint**: Use an `emptyDir` volume for the writable area.

## Context

The application binary is simply `sh -c 'echo "Log entry" >> /var/log/app.log && sleep 3600'`.


## Validation

Verify the pod is running:
```bash
kubectl get pod web-logger
```
Verify `readOnlyRootFilesystem` is still true, but a volume is mounted at `/var/log`:
```bash
kubectl get pod web-logger -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}'
kubectl describe pod web-logger | grep -A 2 Mounts
```
