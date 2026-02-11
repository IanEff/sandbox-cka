#!/bin/bash
# Verify DaemonSet Drill
set -e

echo "Waiting for DaemonSet rollout..."
kubectl rollout status ds/monitor-agent --timeout=60s

# Get Control Plane Node Name
CP_NODE_NAME=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')

if [ -z "$CP_NODE_NAME" ]; then
    echo "ERROR: Could not identify control plane node."
    exit 1
fi

echo "Checking for pod on node: $CP_NODE_NAME"

# Find a pod belonging to the DS on that node
POD_ON_CP=$(kubectl get pods -l name=monitor-agent --field-selector spec.nodeName=$CP_NODE_NAME -o name)
# Note: 'name=monitor-agent' implies the DS adds that label.
# Usually 'kubectl create ds ...' might not add it?
# Better use selector from DS.
SELECTOR=$(kubectl get ds monitor-agent -o jsonpath='{.spec.selector.matchLabels}' | jq -r 'to_entries | map("\(.key)=\(.value)") | join(",")')

POD_ON_CP=""
if [ -n "$SELECTOR" ]; then
    POD_ON_CP=$(kubectl get pods -l "$SELECTOR" --field-selector spec.nodeName=$CP_NODE_NAME -o name)
else
    # Fallback search
    POD_ON_CP=$(kubectl get pods --field-selector spec.nodeName=$CP_NODE_NAME -o name | grep monitor-agent)
fi

if [ -n "$POD_ON_CP" ]; then
    echo "SUCCESS: Found pod $POD_ON_CP running on control plane node."
    exit 0
else
    echo "FAIL: No monitor-agent pod found on control plane node $CP_NODE_NAME."
    # Check if taint is ignored
    echo "Debug: Node Taints:"
    kubectl describe node $CP_NODE_NAME | grep Taint
    exit 1
fi
