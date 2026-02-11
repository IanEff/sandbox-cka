#!/bin/bash
# Verify

# Check SA exists
if ! kubectl get sa secure-sa > /dev/null 2>&1; then
    echo "FAIL: SA 'secure-sa' not found."
    exit 1
fi

# Check SA configuration
AUTO=$(kubectl get sa secure-sa -o jsonpath='{.automountServiceAccountToken}')
if [[ "$AUTO" != "false" ]]; then
    echo "FAIL: SA automountServiceAccountToken is '$AUTO' (expected false)."
    exit 1
fi

# Check Pod exists
if ! kubectl get pod secure-pod > /dev/null 2>&1; then
    echo "FAIL: Pod 'secure-pod' not found."
    exit 1
fi

# Check Pod configuration (it inherits from SA, or can be overridden on Pod)
# If SA has it false, Pod spec should reflect that or NOT have the volume mounted.
# K8s injects the volume if automount is true.
# Use // [] to handle null/empty volumeMounts gracefully in jq
MOUNT=$(kubectl get pod secure-pod -o json | jq '.spec.containers[0].volumeMounts // [] | .[] | select(.mountPath=="/var/run/secrets/kubernetes.io/serviceaccount")')

if [[ -n "$MOUNT" ]]; then
    echo "FAIL: ServiceAccount token volume is still mounted in the pod."
    exit 1
fi

echo "SUCCESS: ServiceAccount created with automount disabled and Pod verified."
exit 0
