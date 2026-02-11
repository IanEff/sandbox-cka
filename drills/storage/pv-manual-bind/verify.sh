#!/bin/bash
NS="manual-bind"

# Check PV
kubectl get pv manual-disk > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "PV manual-disk not found"; exit 1; fi

# Check PVC binding
PVC_STATUS=$(kubectl get pvc manual-pvc -n $NS -o jsonpath='{.status.phase}')
PVC_VOL=$(kubectl get pvc manual-pvc -n $NS -o jsonpath='{.spec.volumeName}')

if [[ "$PVC_STATUS" != "Bound" ]]; then echo "PVC not Bound"; exit 1; fi
if [[ "$PVC_VOL" != "manual-disk" ]]; then echo "PVC bound to wrong volume: $PVC_VOL"; exit 1; fi

# Check Pod Running
POD_STATUS=$(kubectl get pod data-writer -n $NS -o jsonpath='{.status.phase}')
if [[ "$POD_STATUS" != "Running" ]]; then echo "Pod not Running: $POD_STATUS"; exit 1; fi

echo "Manual binding verified."
exit 0
