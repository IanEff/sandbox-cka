#!/bin/bash
set -e

echo "Checking node status..."

# Check if all nodes are Ready
NOT_READY_NODES=$(kubectl get nodes --no-headers | grep -v " Ready" | wc -l | tr -d ' ')

if [ "$NOT_READY_NODES" -eq 0 ]; then
    echo "SUCCESS: All nodes are in Ready status!"
    kubectl get nodes
    exit 0
else
    echo "FAIL: Found $NOT_READY_NODES node(s) not in Ready status."
    kubectl get nodes
    exit 1
fi
