#!/bin/bash
if kubectl get pvc restore-data -n storage-drill -o jsonpath='{.status.phase}' | grep -q "Bound"; then
    echo "SUCCESS: PVC is Bound."
    exit 0
else
    echo "FAIL: PVC is not Bound."
    exit 1
fi
