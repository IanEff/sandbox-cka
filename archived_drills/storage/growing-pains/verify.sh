#!/bin/bash
set -e

echo "Checking PVC resize..."

# Check StorageClass allows expansion
ALLOW_EXPANSION=$(kubectl get sc local-resize -o jsonpath='{.allowVolumeExpansion}' 2>/dev/null || echo "false")

# Check PVC size request
PVC_SIZE=$(kubectl get pvc data-pvc -n resize-test -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null || echo "0")

# Check deployment is running
READY=$(kubectl get deployment data-app -n resize-test -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")

echo "StorageClass allowVolumeExpansion: $ALLOW_EXPANSION"
echo "PVC requested size: $PVC_SIZE"
echo "Deployment ready replicas: $READY"

if [ "$ALLOW_EXPANSION" = "true" ] && [ "$PVC_SIZE" = "5Gi" ] && [ "$READY" = "1" ]; then
    echo "SUCCESS: PVC expanded to 5Gi and deployment running!"
    exit 0
else
    echo "FAIL: PVC not properly resized."
    [ "$ALLOW_EXPANSION" != "true" ] && echo "  - StorageClass does not allow expansion"
    [ "$PVC_SIZE" != "5Gi" ] && echo "  - PVC size is not 5Gi (current: $PVC_SIZE)"
    [ "$READY" != "1" ] && echo "  - Deployment not ready"
    exit 1
fi
