#!/bin/bash
kubectl create ns scheduling-7 --dry-run=client -o yaml | kubectl apply -f -

# Find a worker node (filtering out control-plane)
NODE=$(kubectl get nodes --no-headers | grep -v "control-plane" | head -n1 | awk '{print $1}')

if [ -z "$NODE" ]; then
    # Fallback to control plane if single node cluster, but warn
    NODE=$(kubectl get nodes --no-headers | head -n1 | awk '{print $1}')
fi

echo "Setting up node: $NODE"

# Idempotency: Reset taint/label just to be sure we are in known state
kubectl label node $NODE maintenance- 2>/dev/null
kubectl taint node $NODE maintenance- 2>/dev/null

# Taint only (User must add label)
# kubectl label node $NODE maintenance=true --overwrite  <-- Removed as per problem instructions
kubectl taint node $NODE maintenance=true:NoSchedule --overwrite

# Ensure label is GONE so the user has to add it
kubectl label node $NODE maintenance- 2>/dev/null

# Clean up any previous pod attempts
kubectl delete pod sys-admin-pod -n scheduling-7 --ignore-not-found
