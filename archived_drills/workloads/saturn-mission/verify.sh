#!/bin/bash

# Check if pod is running
STATUS=$(kubectl get pod cassini -n mission-control -o jsonpath='{.status.phase}')

if [ "$STATUS" == "Running" ]; then
    echo "SUCCESS: Cassini is orbiting!"
else
    echo "FAIL: Cassini is currently $STATUS"
    exit 1
fi
