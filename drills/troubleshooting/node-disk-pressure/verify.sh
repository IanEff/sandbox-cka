#!/bin/bash
set -e

# Find the node that was tainted
TAINTED_NODE=$(kubectl get nodes -o json | jq -r '.items[] | select(.spec.taints[]? | select(.key=="node.kubernetes.io/disk-pressure")) | .metadata.name' | head -n1)

if [ -z "$TAINTED_NODE" ]; then
    echo "✅ No nodes with disk-pressure taint found (issue resolved)"
    exit 0
fi

echo "❌ Node '$TAINTED_NODE' still has disk-pressure taint"
echo "Hint: Remove the taint and annotation to resolve this drill"
exit 1
