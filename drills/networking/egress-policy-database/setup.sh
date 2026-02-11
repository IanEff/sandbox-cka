#!/bin/bash
# Setup for Egress NetworkPolicy Drill
set -e

# Cleanup
kubectl delete ns secure-app --ignore-not-found=true --wait=true

# Create namespace
kubectl create ns secure-app

# Label kube-system namespace for namespaceSelector (idempotent)
kubectl label ns kube-system name=kube-system --overwrite

# Create database pod
kubectl run database --image=nginx:alpine -n secure-app --labels=app=database --port=5432
kubectl expose pod database --port=5432 --target-port=80 -n secure-app --name=database-svc

# Create API pod that needs to be restricted
kubectl run api-server --image=nginx:alpine -n secure-app --labels=role=api

# Create a "forbidden" service pod that api should NOT be able to reach
kubectl run forbidden-svc --image=nginx:alpine -n secure-app --labels=app=forbidden --port=8080
kubectl expose pod forbidden-svc --port=8080 --target-port=80 -n secure-app --name=forbidden

# Wait for pods
kubectl wait --for=condition=ready pod -l app=database -n secure-app --timeout=60s
kubectl wait --for=condition=ready pod -l role=api -n secure-app --timeout=60s
kubectl wait --for=condition=ready pod -l app=forbidden -n secure-app --timeout=60s

echo "Setup complete."
echo "Create NetworkPolicy 'restricted-egress' to allow api pods to reach only DNS and database:5432"
