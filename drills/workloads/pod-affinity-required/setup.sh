#!/bin/bash
# Setup for Pod Affinity Drill
set -e

# Cleanup
kubectl delete deploy redis-cache --ignore-not-found=true
kubectl delete pod backend-app --ignore-not-found=true --wait=true

# Create Backend App on a node (let scheduler decide, but we need it running)
kubectl run backend-app --image=nginx:alpine --labels=app=backend

# Wait for backend to be scheduled
echo "Waiting for backend-app to be scheduled..."
kubectl wait --for=condition=ready pod/backend-app --timeout=60s

echo "Setup complete. Pod 'backend-app' is running."
