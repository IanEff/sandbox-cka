#!/bin/bash
set -e

# Create namespace
kubectl create namespace public --dry-run=client -o yaml | kubectl apply -f -

# Setup verify will check for the deployment and service creation
# We don't create broken state here, we let the user build it from scratch or we could create a ClusterIP service they need to change.
# Let's clean up any previous state to ensure a clean slate
kubectl delete service lb-service -n public --ignore-not-found
kubectl delete deployment lb-app -n public --ignore-not-found

echo "Setup complete. Create deployment 'lb-app' and expose it via LoadBalancer service 'lb-service' in namespace 'public'."
