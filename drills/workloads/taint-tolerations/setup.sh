#!/bin/bash
set -e

# Create namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Find a worker node (not control plane)
WORKER_NODE=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')

if [[ -z "$WORKER_NODE" ]]; then
  echo "ERROR: No worker node found"
  exit 1
fi

# Apply taint to worker node (idempotent)
kubectl taint nodes "$WORKER_NODE" monitoring=true:NoSchedule --overwrite || true

echo "Setup complete. Node $WORKER_NODE is tainted with monitoring=true:NoSchedule"
echo "Create pod 'monitor-agent' in namespace 'monitoring' that can schedule on this node"
