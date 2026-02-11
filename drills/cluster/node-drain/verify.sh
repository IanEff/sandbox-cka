#!/bin/bash
# 1. Check cordon status
if ! kubectl get node ubukubu-node-1 -o jsonpath='{.spec.unschedulable}' | grep -q "true"; then
    echo "FAIL: Node ubukubu-node-1 is not cordoned."
    exit 1
fi

# 2. Check for pods on that node in the target namespace
COUNT=$(kubectl get pods -n cluster-ops --field-selector spec.nodeName=ubukubu-node-1 --no-headers | wc -l | xargs)
if [ "$COUNT" -gt 0 ]; then
    echo "FAIL: There are still $COUNT pods on ubukubu-node-1 in namespace cluster-ops."
    exit 1
fi

echo "SUCCESS: Node is drained and cordoned."
exit 0
