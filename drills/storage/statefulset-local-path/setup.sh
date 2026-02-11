#!/bin/bash
set -e

# Clean up
kubectl delete statefulset kv-store -n data --ignore-not-found
kubectl delete pvc -l app=kv-store -n data --ignore-not-found
kubectl delete ns data --ignore-not-found

# Create namespace
kubectl create namespace data --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete. Create StatefulSet 'kv-store' in 'data' namespace using 'local-path' storage class."
