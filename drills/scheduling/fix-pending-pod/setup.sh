#!/bin/bash
kubectl delete ns scheduling-drill --ignore-not-found
kubectl create ns scheduling-drill

# Ensure nodes do NOT have the label
kubectl label nodes --all tier- > /dev/null 2>&1

# Create Deployment
kubectl create deployment important-work --image=nginx:alpine --replicas=1 -n scheduling-drill
# Patch it to require the label
kubectl patch deployment important-work -n scheduling-drill -p '{"spec": {"template": {"spec": {"nodeSelector": {"tier": "gold"}}}}}'

echo "Deployment created. Pods should be pending."
