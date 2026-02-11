#!/bin/bash
# Verify for node-cordon-uncordon

NODE="ubukubu-node-1"

# Check if node is unschedulable
UNSCHED=$(kubectl get node $NODE -o jsonpath='{.spec.unschedulable}')

if [ "$UNSCHED" != "true" ]; then
    echo "FAIL: Node $NODE is currently schedulable (unschedulable != true)"
    exit 1
fi

echo "SUCCESS: Node $NODE is cordoned."
