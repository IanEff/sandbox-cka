#!/bin/bash
# Setup: Simulate disk pressure on a worker node

# Find a worker node
WORKER_NODE=$(kubectl get nodes -o jsonpath='{.items[?(@.metadata.name!="ubukubu-control")].metadata.name}' | awk '{print $1}')

if [ -z "$WORKER_NODE" ]; then
    echo "No worker node found, using control plane"
    WORKER_NODE="ubukubu-control"
fi

# Taint the node to simulate disk pressure
kubectl taint nodes $WORKER_NODE node.kubernetes.io/disk-pressure=:NoSchedule --overwrite &>/dev/null || true

# Add a condition annotation (simulation - in real scenario kubelet would do this)
kubectl annotate node $WORKER_NODE drill.simulation/disk-pressure=true --overwrite &>/dev/null

echo "Simulated disk pressure on node $WORKER_NODE"
echo "In a real scenario, you would need to free up disk space on the node"
exit 0
