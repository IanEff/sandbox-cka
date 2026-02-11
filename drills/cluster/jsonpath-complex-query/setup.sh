#!/bin/bash
# Setup for JSONPath Drill
set -e

# Setup directory
sudo mkdir -p /opt/course/drill
sudo chown -R vagrant:vagrant /opt/course

# Clean up
rm -f /opt/course/drill/jsonpath.txt
kubectl delete ns jsonpath-drill --ignore-not-found=true --wait=true

# Create resources
kubectl create ns jsonpath-drill

# Create Pods with delays to ensure distinct creationTimestamps
kubectl run pod-early --image=nginx:alpine -n jsonpath-drill
sleep 2
kubectl run pod-mid --image=nginx:alpine -n jsonpath-drill
sleep 2
kubectl run pod-late --image=nginx:alpine -n jsonpath-drill

echo "Waiting for pods to be scheduled..."
kubectl wait --for=condition=ready pod -l run=pod-early -n jsonpath-drill --timeout=60s
kubectl wait --for=condition=ready pod -l run=pod-mid -n jsonpath-drill --timeout=60s
kubectl wait --for=condition=ready pod -l run=pod-late -n jsonpath-drill --timeout=60s

echo "Setup complete. Namespace 'jsonpath-drill' ready."
