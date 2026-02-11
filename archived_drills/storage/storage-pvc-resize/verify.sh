#!/bin/bash
# Verify for storage-pvc-resize drill

if kubectl get pvc data-claim -o jsonpath='{.spec.resources.requests.storage}' | grep -q "100Mi"; then
    echo "SUCCESS: PVC request resized to 100Mi."
    exit 0
else
    echo "FAILURE: PVC size is not 100Mi."
    exit 1
fi
