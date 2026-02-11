#!/bin/bash
# cluster/maintenance-node-drain/verify.sh

# 1. Check SchedulingDisabled
if ! kubectl get node ubukubu-node-1 | grep -q "SchedulingDisabled"; then
  echo "FAIL: ubukubu-node-1 is not cordoned."
  exit 1
fi

# 2. Check for regular pods on the node
# We ignore DaemonSets (kube-system things mostly)
PODS_ON_NODE=$(kubectl get pods --all-namespaces --field-selector spec.nodeName=ubukubu-node-1 --no-headers | grep -v "DaemonSet" | grep "drain-test")

if [ ! -z "$PODS_ON_NODE" ]; then
    echo "FAIL: Found pods on ubukubu-node-1:"
    echo "$PODS_ON_NODE"
    exit 1
fi

echo "SUCCESS: Node drained successfully."
