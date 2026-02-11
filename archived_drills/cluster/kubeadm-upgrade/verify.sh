#!/bin/bash
set -e

echo "Checking maintenance drill completion..."

# Check node is schedulable (not cordoned)
NODE_SCHEDULABLE=$(kubectl get node ubukubu-node-1 -o jsonpath='{.spec.unschedulable}' 2>/dev/null || echo "true")

# Check deployment is healthy
READY_REPLICAS=$(kubectl get deployment critical-app -n maintenance-test -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
DESIRED_REPLICAS=$(kubectl get deployment critical-app -n maintenance-test -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "3")

echo "Node ubukubu-node-1 unschedulable: $NODE_SCHEDULABLE"
echo "Deployment ready replicas: $READY_REPLICAS / $DESIRED_REPLICAS"

# Node should be schedulable (unschedulable should be empty or false)
if [ "$NODE_SCHEDULABLE" = "true" ]; then
    echo "FAIL: Node ubukubu-node-1 is still cordoned (unschedulable)."
    exit 1
fi

# All replicas should be ready
if [ "$READY_REPLICAS" != "$DESIRED_REPLICAS" ]; then
    echo "FAIL: Deployment not fully available ($READY_REPLICAS/$DESIRED_REPLICAS ready)."
    exit 1
fi

echo "SUCCESS: Node is schedulable and deployment is healthy!"
exit 0
