#!/bin/bash
# Setup for NetworkPolicy Drill
set -e

# Cleanup
kubectl delete ns restricted trusted other --ignore-not-found=true --wait=true

# Create Namespaces
kubectl create ns restricted
kubectl create ns trusted
kubectl create ns other

# Label Trusted NS (in case user uses namespaceSelector matchesLabels)
kubectl label ns trusted name=trusted

# Create Target Pod in Restricted
kubectl run web --image=nginx:alpine -n restricted --labels=app=web --port=80
kubectl expose pod web --port=80 -n restricted --name=web-svc

# Wait for pod
kubectl wait --for=condition=ready pod/web -n restricted --timeout=60s

echo "Setup complete. Namespace 'restricted' has web server running."
