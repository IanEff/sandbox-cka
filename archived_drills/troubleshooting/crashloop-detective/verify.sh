#!/bin/bash
set -e

# Check if the pod is running
STATUS=$(kubectl get pod webapp -n crashloop-ns -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
READY=$(kubectl get pod webapp -n crashloop-ns -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")

echo "Pod status: $STATUS, Ready: $READY"

if [ "$STATUS" = "Running" ] && [ "$READY" = "true" ]; then
    echo "SUCCESS: Pod webapp is running and ready!"
    exit 0
else
    echo "FAIL: Pod webapp is not running (status=$STATUS, ready=$READY)."
    exit 1
fi
