#!/bin/bash
set -e

# Pick the first worker node
WORKER_NODE=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$WORKER_NODE" ]; then
    echo "ERROR: No worker nodes found."
    exit 1
fi

echo "Breaking kubelet config on $WORKER_NODE..."

# SSH to worker and corrupt the kubelet config
# We'll add an invalid flag to the kubelet arguments in the systemd drop-in or config file.
# A common way is to modify /var/lib/kubelet/config.yaml
ssh -o StrictHostKeyChecking=no "$WORKER_NODE" "sudo sed -i 's/staticPodPath:/staticPodPathTypo:/' /var/lib/kubelet/config.yaml && sudo systemctl restart kubelet"

echo "Waiting for node to become NotReady..."
# It might take a moment for the node controller to mark it NotReady
sleep 10

echo "Setup complete. $WORKER_NODE should be broken."
