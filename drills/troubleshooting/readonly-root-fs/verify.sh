#!/bin/bash
# Verify: Pod is Running and readOnlyRootFilesystem is still true

# 1. Check Pod is Running
STATUS=$(kubectl get pod web-logger -o jsonpath='{.status.phase}')
if [[ "$STATUS" != "Running" ]]; then
    echo "FAIL: Pod web-logger is not Running (Current status: $STATUS)"
    exit 1
fi

# 2. Check SecurityContext is still enforced
RO=$(kubectl get pod web-logger -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}')
if [[ "$RO" != "true" ]]; then
    echo "FAIL: readOnlyRootFilesystem was removed or set to false. Security constraint violated."
    exit 1
fi

# 3. Check if volume is mounted at /var/log (implicit check: if it's finding /var/log writable while RO is true, it MUST be a volume)
# We can strictly check mounts if we want, but running is proof enough given the command.
log_mount=$(kubectl get pod web-logger -o json | jq -r '.spec.containers[0].volumeMounts[] | select(.mountPath=="/var/log")')

if [[ -z "$log_mount" ]]; then
    echo "FAIL: No volume mounted at /var/log to bypass read-only root."
    exit 1
fi

echo "SUCCESS: Pod is running with read-only root filesytem."
exit 0
