#!/bin/bash
set -e

# verify SA exists and has automountServiceAccountToken: false
SA_AUTOMOUNT=$(kubectl get sa no-token-sa -n security -o jsonpath='{.automountServiceAccountToken}')
if [ "$SA_AUTOMOUNT" != "false" ]; then
    echo "FAIL: ServiceAccount 'no-token-sa' does not have automountServiceAccountToken set to false."
    exit 1
fi

# verify pod is running
kubectl wait --for=condition=ready pod/secure-pod -n security --timeout=60s > /dev/null

# verify pod uses the correct SA
POD_SA=$(kubectl get pod secure-pod -n security -o jsonpath='{.spec.serviceAccountName}')
if [ "$POD_SA" != "no-token-sa" ]; then
    echo "FAIL: Pod 'secure-pod' is not using ServiceAccount 'no-token-sa'."
    exit 1
fi

# verify token is NOT mounted
# We check if the volume mount for serviceaccount exists. standard mount is at /var/run/secrets/kubernetes.io/serviceaccount
MOUNT_CHECK=$(kubectl get pod secure-pod -n security -o jsonpath='{range .spec.containers[*].volumeMounts[*]}{.mountPath}{"\n"}{end}' | grep "/var/run/secrets/kubernetes.io/serviceaccount" || true)

if [ -n "$MOUNT_CHECK" ]; then
    echo "FAIL: Found service account token mount in Pod 'secure-pod'."
    exit 1
fi

echo "SUCCESS: ServiceAccount and Pod configured correctly."
