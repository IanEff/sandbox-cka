#!/bin/bash

NS="drill-storage"
POD="data-pod"

# Check Pod exists and is Ready
kubectl wait --for=condition=ready pod $POD -n $NS --timeout=10s || exit 1

# Check PVC usage
USED_PVC=$(kubectl get pod $POD -n $NS -o jsonpath='{.spec.volumes[?(@.name=="data-vol")].persistentVolumeClaim.claimName}')
if [ "$USED_PVC" != "large-pvc" ]; then
    echo "Fail: Pod is using $USED_PVC, expected large-pvc"
    exit 1
fi

# Check PVC Size
CAPACITY=$(kubectl get pvc large-pvc -n $NS -o jsonpath='{.status.capacity.storage}')
if [ "$CAPACITY" != "200Mi" ]; then
    echo "Fail: large-pvc is $CAPACITY, expected 200Mi"
    exit 1
fi

# Check Data
DATA=$(kubectl exec $POD -n $NS -- cat /data/important.txt 2>/dev/null)
if [[ "$DATA" == *"DO_NOT_LOSE_THIS"* ]]; then
    echo "Success: Data preserved."
    exit 0
else
    echo "Fail: Data lost. Found: '$DATA'"
    exit 1
fi
