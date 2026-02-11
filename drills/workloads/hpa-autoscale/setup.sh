#!/bin/bash
set -e

# Cleanup
kubectl delete ns scaling --ignore-not-found

# Create namespace
kubectl create namespace scaling --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete. Namespace 'scaling' ready."
