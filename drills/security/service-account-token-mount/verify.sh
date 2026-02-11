#!/bin/bash
# security/service-account-token-mount/verify.sh

# 1. Check Pod exists
if ! kubectl get pod no-token > /dev/null 2>&1; then
    echo "FAIL: Pod 'no-token' not found."
    exit 1
fi

# 2. Check spec
AUTOMOUNT=$(kubectl get pod no-token -o jsonpath='{.spec.automountServiceAccountToken}')
if [ "$AUTOMOUNT" != "false" ]; then
    echo "FAIL: automountServiceAccountToken is '$AUTOMOUNT' (expected 'false')."
    exit 1
fi

# 3. Check for the volume (double check)
MOUNTS=$(kubectl get pod no-token -o jsonpath='{.spec.containers[0].volumeMounts[*].mountPath}')
if echo "$MOUNTS" | grep -q "serviceaccount"; then
    echo "FAIL: Found serviceaccount mount in container."
    exit 1
fi

echo "SUCCESS: Token mount disabled."
