#!/bin/bash
set -e

# This drill stops the kubelet on the first worker node to simulate a NotReady condition.
# The user must SSH to the worker and restart kubelet.

WORKER_NODE=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$WORKER_NODE" ]; then
    echo "ERROR: No worker nodes found in cluster."
    exit 1
fi

echo "Stopping kubelet on $WORKER_NODE..."

# SSH from control plane to worker node to stop kubelet
ssh -o StrictHostKeyChecking=no "$WORKER_NODE" "sudo systemctl stop kubelet" 2>/dev/null || \
    echo "Note: Could not SSH to worker. Trying direct command..."

# Wait for node to show NotReady
echo "Waiting for node status to reflect change..."
sleep 5

echo "Setup complete. A worker node should now show NotReady status."
echo "Use 'kubectl get nodes' to identify the affected node."
