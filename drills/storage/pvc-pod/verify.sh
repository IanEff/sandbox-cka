#!/bin/bash
NS="sci-storage"

# 1. Check PV
kubectl get pv sci-pv >/dev/null 2>&1 || { echo "FAIL: PV 'sci-pv' not found"; exit 1; }
ACCESS=$(kubectl get pv sci-pv -o jsonpath='{.spec.accessModes[0]}')
if [ "$ACCESS" != "ReadWriteMany" ]; then echo "FAIL: PV AccessMode wrong"; exit 1; fi

# 2. Check PVC Bound
STATUS=$(kubectl get pvc sci-pvc -n $NS -o jsonpath='{.status.phase}')
if [ "$STATUS" != "Bound" ]; then echo "FAIL: PVC not Bound (Current: $STATUS)"; exit 1; fi

# 3. Check Pod Mount
kubectl wait --for=condition=ready pod/data-processor -n $NS --timeout=30s
kubectl exec -n $NS data-processor -- grep -q "Processing" /data/status
if [ $? -ne 0 ]; then
    echo "FAIL: File /data/status not writable/readable in Pod"
    exit 1
fi

echo "Verification success"
exit 0
