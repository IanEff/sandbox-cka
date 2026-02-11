#!/bin/bash
PV_STATUS=$(kubectl get pv manual-pv -o jsonpath='{.status.phase}')
PVC_STATUS=$(kubectl get pvc manual-pvc -o jsonpath='{.status.phase}')
PVC_PV=$(kubectl get pvc manual-pvc -o jsonpath='{.spec.volumeName}')

if [[ "$PV_STATUS" != "Bound" ]]; then echo "PV not Bound"; exit 1; fi
if [[ "$PVC_STATUS" != "Bound" ]]; then echo "PVC not Bound"; exit 1; fi
if [[ "$PVC_PV" != "manual-pv" ]]; then echo "PVC bound to wrong PV"; exit 1; fi
