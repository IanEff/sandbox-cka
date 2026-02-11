#!/bin/bash
set -e

echo "Checking PV reclaim rescue..."

# Check PV status
PV_STATUS=$(kubectl get pv archive-pv -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
PV_CLAIMREF=$(kubectl get pv archive-pv -o jsonpath='{.spec.claimRef.name}' 2>/dev/null || echo "")

# Check new PVC exists and is bound
PVC_STATUS=$(kubectl get pvc archive-pvc -n reclaim-ns -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")

echo "PV status: $PV_STATUS"
echo "PV claimRef: ${PV_CLAIMREF:-none}"
echo "PVC status: $PVC_STATUS"

if [ "$PV_STATUS" = "Bound" ] && [ "$PVC_STATUS" = "Bound" ] && [ "$PV_CLAIMREF" = "archive-pvc" ]; then
    echo "SUCCESS: PV is bound to archive-pvc!"
    exit 0
else
    echo "FAIL: PV not properly rescued."
    [ "$PV_STATUS" != "Bound" ] && echo "  - PV is not Bound (current: $PV_STATUS)"
    [ "$PVC_STATUS" != "Bound" ] && echo "  - PVC is not Bound (current: $PVC_STATUS)"
    exit 1
fi
