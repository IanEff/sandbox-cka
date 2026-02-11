#!/bin/bash
# Verify Storage Backup Job Drill
set -e

NS="backup-system"

# Check StorageClass exists with correct settings
if ! kubectl get storageclass backup-storage >/dev/null 2>&1; then
    echo "FAIL: StorageClass 'backup-storage' not found"
    exit 1
fi

RECLAIM=$(kubectl get storageclass backup-storage -o jsonpath='{.reclaimPolicy}')
if [[ "$RECLAIM" != "Retain" ]]; then
    echo "FAIL: StorageClass reclaimPolicy is '$RECLAIM', expected 'Retain'"
    exit 1
fi
echo "PASS: StorageClass has Retain policy"

BINDING=$(kubectl get storageclass backup-storage -o jsonpath='{.volumeBindingMode}')
if [[ "$BINDING" != "WaitForFirstConsumer" ]]; then
    echo "FAIL: StorageClass volumeBindingMode is '$BINDING', expected 'WaitForFirstConsumer'"
    exit 1
fi
echo "PASS: StorageClass has WaitForFirstConsumer binding mode"

# Check PVC exists and is bound
if ! kubectl get pvc backup-pvc -n $NS >/dev/null 2>&1; then
    echo "FAIL: PVC 'backup-pvc' not found in namespace $NS"
    exit 1
fi

PVC_STATUS=$(kubectl get pvc backup-pvc -n $NS -o jsonpath='{.status.phase}')
if [[ "$PVC_STATUS" != "Bound" ]]; then
    echo "FAIL: PVC status is '$PVC_STATUS', expected 'Bound'"
    exit 1
fi
echo "PASS: PVC is Bound"

# Check Job completed
if ! kubectl get job backup-job -n $NS >/dev/null 2>&1; then
    echo "FAIL: Job 'backup-job' not found in namespace $NS"
    exit 1
fi

# Wait for job completion with timeout
timeout 60 kubectl wait --for=condition=complete job/backup-job -n $NS --timeout=55s || {
    echo "FAIL: Job did not complete within timeout"
    exit 1
}

echo "SUCCESS: Backup Job with retained PVC completed correctly"
