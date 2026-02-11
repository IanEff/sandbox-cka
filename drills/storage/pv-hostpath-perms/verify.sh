#!/bin/bash
# Verify for pv-hostpath-perms

# 1. Check PV details
HP_TYPE=$(kubectl get pv local-store -o jsonpath='{.spec.hostPath.type}')
HP_PATH=$(kubectl get pv local-store -o jsonpath='{.spec.hostPath.path}')

if [ "$HP_TYPE" != "DirectoryOrCreate" ]; then
    echo "FAIL: PV local-store hostPath.type is '$HP_TYPE', expected 'DirectoryOrCreate'"
    exit 1
fi

if [ "$HP_PATH" != "/var/data/project-x" ]; then
    echo "FAIL: PV local-store hostPath.path is '$HP_PATH', expected '/var/data/project-x'"
    exit 1
fi

# 2. Check PVC Bound
STATUS=$(kubectl get pvc local-claim -o jsonpath='{.status.phase}')
if [ "$STATUS" != "Bound" ]; then
    echo "FAIL: PVC local-claim is '$STATUS', expected 'Bound'"
    exit 1
fi

# 3. Check Pod running and writing
POD_STATUS=$(kubectl get pod writer -o jsonpath='{.status.phase}')
if [ "$POD_STATUS" != "Running" ]; then
    echo "FAIL: Pod writer is '$POD_STATUS', expected 'Running'"
    exit 1
fi

# Verify file content
CONTENT=$(kubectl exec writer -- cat /mnt/data/index.html 2>/dev/null)
if [[ "$CONTENT" != *"Hello World"* ]]; then
    echo "FAIL: File /mnt/data/index.html does not contain 'Hello World'"
    exit 1
fi

echo "SUCCESS: PV, PVC, and Pod configured correctly."
