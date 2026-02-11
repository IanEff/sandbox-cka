#!/bin/bash
set -e

# Verification Script

# 1. Check Namespace
kubectl get ns block-world > /dev/null

# 2. Check PV
PV_MODE=$(kubectl get pv block-pv -o jsonpath='{.spec.volumeMode}')
if [ "$PV_MODE" != "Block" ]; then
    echo "FAIL: block-pv volumeMode is $PV_MODE, expected Block"
    exit 1
fi
PV_SC=$(kubectl get pv block-pv -o jsonpath='{.spec.storageClassName}')
if [ "$PV_SC" != "manual-block" ]; then
    echo "FAIL: block-pv storageClassName is $PV_SC, expected manual-block"
    exit 1
fi

# 3. Check PVC
PVC_MODE=$(kubectl get pvc block-pvc -n block-world -o jsonpath='{.spec.volumeMode}')
if [ "$PVC_MODE" != "Block" ]; then
    echo "FAIL: block-pvc volumeMode is $PVC_MODE, expected Block"
    exit 1
fi
PVC_STATUS=$(kubectl get pvc block-pvc -n block-world -o jsonpath='{.status.phase}')
if [ "$PVC_STATUS" != "Bound" ]; then
    echo "FAIL: block-pvc is $PVC_STATUS, expected Bound"
    exit 1
fi

# 4. Check Pod
POD_DEV=$(kubectl get pod block-pod -n block-world -o jsonpath='{.spec.containers[0].volumeDevices[0].devicePath}')
if [ "$POD_DEV" != "/dev/xvda" ]; then
    echo "FAIL: block-pod device path is $POD_DEV, expected /dev/xvda"
    exit 1
fi

echo "SUCCESS: Block volume drill passed."
