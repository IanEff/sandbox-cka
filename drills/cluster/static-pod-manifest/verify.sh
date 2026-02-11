#!/bin/bash
# cluster/static-pod-manifest/verify.sh

# Check for the mirror pod
if ! kubectl get pod | grep -q "static-web-ubukubu-control"; then
    echo "FAIL: Mirror pod 'static-web-ubukubu-control' not found."
    exit 1
fi

# Double check it is running
STATUS=$(kubectl get pod static-web-ubukubu-control -o jsonpath='{.status.phase}')
if [ "$STATUS" != "Running" ]; then
    echo "FAIL: Pod is $STATUS (expected Running)."
    exit 1
fi

echo "SUCCESS: Static pod found."
