#!/bin/bash
# Setup for DaemonSet Drill
set -e

# Cleanup
kubectl delete ds monitor-agent --ignore-not-found=true

# Ensure Control Plane Taint exists (standard Kubeadm taint)
# We won't force apply it if it's missing (user might have untainted it), but we'll warn.
CP_NODE=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o name | head -n1)

if [ -z "$CP_NODE" ]; then
    echo "WARNING: No control-plane node found with label 'node-role.kubernetes.io/control-plane'. Drill might be easy."
else
    # Check for taint
    if ! kubectl describe $CP_NODE | grep -q "node-role.kubernetes.io/control-plane:NoSchedule"; then
        echo "Note: Control plane node does not have standard NoSchedule taint. Applying it for the drill..."
        kubectl taint nodes $(echo $CP_NODE | cut -d/ -f2) node-role.kubernetes.io/control-plane:NoSchedule --overwrite
    fi
fi

echo "Setup complete."
