#!/bin/bash
# Setup for DaemonSet All Nodes Drill
set -e

# Cleanup
kubectl delete ns monitoring --ignore-not-found=true --wait=true

# Create namespace
kubectl create ns monitoring

# Count nodes for verification info
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
CONTROL_PLANE=$(kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers -o custom-columns=NAME:.metadata.name)

echo "Setup complete."
echo "Cluster has $NODE_COUNT nodes."
echo "Control plane node: $CONTROL_PLANE"
echo "Create DaemonSet 'log-collector' that runs on ALL nodes including control plane."
