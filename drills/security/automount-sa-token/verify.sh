#!/bin/bash
# Verify for automount-sa-token

# 1. Check ServiceAccount exists
if ! kubectl get sa secure-bot >/dev/null 2>&1; then
    echo "FAIL: ServiceAccount secure-bot not found"
    exit 1
fi

# 2. Check Pod runs with correct SA
SA_NAME=$(kubectl get pod paranoid-pod -o jsonpath='{.spec.serviceAccountName}')
if [ "$SA_NAME" != "secure-bot" ]; then
    echo "FAIL: Pod paranoid-pod uses SA '$SA_NAME', expected 'secure-bot'"
    exit 1
fi

# 3. Check for token mount existence logic
# There are two ways to disable:
# A. ServiceAccount has automountServiceAccountToken: false
# B. Pod has automountServiceAccountToken: false
# The resulting running pod should NOT have the volume mount.

MOUNT_CHECK=$(kubectl exec paranoid-pod -- ls /var/run/secrets/kubernetes.io/serviceaccount 2>&1)
if [[ "$MOUNT_CHECK" != *"No such file or directory"* ]]; then
    # It might be empty if not mounted? No, the directory usually implies the mount exists.
    # Let's check the Pod spec for the VolumeMount.
    
    # Check if the token volume is mounted
    VOL_MOUNT=$(kubectl get pod paranoid-pod -o json | jq '.spec.containers[0].volumeMounts[] | select(.mountPath=="/var/run/secrets/kubernetes.io/serviceaccount")')
    
    if [ -n "$VOL_MOUNT" ]; then
         echo "FAIL: Token volume is still mounted in the Pod."
         exit 1
    fi
fi

# Also check explicit configuration for robustness
SA_AUTO=$(kubectl get sa secure-bot -o jsonpath='{.automountServiceAccountToken}')
POD_AUTO=$(kubectl get pod paranoid-pod -o jsonpath='{.spec.automountServiceAccountToken}')

if [ "$SA_AUTO" != "false" ] && [ "$POD_AUTO" != "false" ]; then
    echo "FAIL: Neither ServiceAccount nor Pod has automountServiceAccountToken: false explicitly set."
    exit 1
fi

echo "SUCCESS: Token mount disabled correctly."
