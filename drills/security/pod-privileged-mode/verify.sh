#!/bin/bash
# Verify for pod-privileged-mode

NS="security-zone"
POD="root-access"

# Check Privileged Flag
PRIV=$(kubectl -n $NS get pod $POD -o jsonpath='{.spec.containers[0].securityContext.privileged}')

if [ "$PRIV" != "true" ]; then
    echo "FAIL: Privileged mode is '$PRIV', expected 'true'"
    exit 1
fi

echo "SUCCESS: Pod is privileged."
