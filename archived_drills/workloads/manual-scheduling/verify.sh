#!/bin/bash
# Verify the pod exists and is running
POD_STATUS=$(kubectl get pod manual-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" != "Running" ]; then
    echo "FAIL: Pod 'manual-pod' is not Running. Status: $POD_STATUS"
    exit 1
fi

# Verify it is on the correct node
NODE_NAME=$(kubectl get pod manual-pod -o jsonpath='{.spec.nodeName}')
if [ "$NODE_NAME" != "ubukubu-node-1" ]; then
    echo "FAIL: Pod scheduled on '$NODE_NAME', expected 'ubukubu-node-1'"
    exit 1
fi

# Verify no nodeSelector was used (optional, but requested in constraints)
SELECTOR=$(kubectl get pod manual-pod -o jsonpath='{.spec.nodeSelector}')
if [ -n "$SELECTOR" ] && [ "$SELECTOR" != "null" ]; then
    echo "FAIL: nodeSelector was used."
    exit 1
fi

echo "SUCCESS: Pod correctly manually scheduled."
