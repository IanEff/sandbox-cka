#!/bin/bash
kubectl create ns mission-control --dry-run=client -o yaml | kubectl apply -f -

# Taint the node
# Assuming a standard 2-node cluster where node-1 is a worker.
# We'll try to find a worker node name dynamically, simpler to just assume or try to target all workers.
# Let's target the first non-control-plane node found.
NODE=$(kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name | grep -v control | head -n1)

if [ -z "$NODE" ]; then
  # Fallback if no worker nodes found (single node cluster?), taint the control plane if it allows work?
  # Safest is just to taint whatever node exists that isn't master if possible, or just fail if no workers.
  # Let's assume standard vagrant setup: ubukubu-node-0 or 1.
  NODE="ubukubu-node-1"
fi

echo "Tainting node $NODE..."
kubectl taint nodes $NODE radiation=high:NoSchedule --overwrite

# Create the pod
kubectl run cassini --image=nginx -n mission-control --overrides='{"spec": {"nodeSelector": {"kubernetes.io/hostname": "'$NODE'"}}}'
