#!/bin/bash

# Check if pod is Running
STATUS=$(kubectl get pod site-init -o jsonpath='{.status.phase}')
if [ "$STATUS" != "Running" ]; then
    echo "FAIL: Pod site-init is not Running (status is '$STATUS')"
    # Check init container status specifically for details
    INIT_STATE=$(kubectl get pod site-init -o jsonpath='{.status.initContainerStatuses[0].state}')
    echo "Init Container State: $INIT_STATE"
    exit 1
fi

echo "SUCCESS: Pod site-init is Running."
