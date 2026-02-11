#!/bin/bash

# 1. Check for toleration
TOLERATION=$(kubectl get daemonset monitoring-agent -o jsonpath='{.spec.template.spec.tolerations}')

# We expect toleration for node-role.kubernetes.io/control-plane
# Can check for "Exists" or specific key
if [[ "$TOLERATION" != *"node-role.kubernetes.io/control-plane"* ]]; then
    echo "FAIL: DaemonSet does not appear to tolerate node-role.kubernetes.io/control-plane. Found: $TOLERATION"
    exit 1
fi

# 2. Check pod count on nodes
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
CURRENT_PODS=$(kubectl get pods -l name=monitoring-agent --no-headers | grep Running | wc -l)

# Wait a bit if needed? No, verify is immediate check usually. 
# But let's be lenient if it's creating.
if [ "$CURRENT_PODS" -lt "$TOTAL_NODES" ]; then
    echo "FAIL: Expected $TOTAL_NODES running pods, found $CURRENT_PODS. Is it scheduled on control plane?"
    exit 1
fi

# 3. Check file output
FILE="/opt/course/3/count.txt"
if [ ! -f "$FILE" ]; then
    echo "FAIL: File $FILE does not exist."
    exit 1
fi

COUNT=$(cat "$FILE")
# Trim whitespace
COUNT=$(echo "$COUNT" | xargs)

if [ "$COUNT" != "$TOTAL_NODES" ]; then
    echo "FAIL: File content is '$COUNT', expected '$TOTAL_NODES'."
    exit 1
fi

echo "SUCCESS: DaemonSet running on all nodes and count file correct."
