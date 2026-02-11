#!/bin/bash
# Verify for operator-repair drill

# Check if pod is running
if kubectl get pod dummy-operator | grep -q "Running"; then
    # Check logs for success message
    if kubectl logs dummy-operator | grep -q "Watching ConfigMaps..."; then
        echo "SUCCESS: Operator is running and watching ConfigMaps."
        exit 0
    fi
fi

echo "FAILURE: Operator is not running correctly or logs do not show success."
exit 1
