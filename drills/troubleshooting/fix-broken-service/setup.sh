#!/bin/bash
kubectl delete ns debug-drill --ignore-not-found
kubectl create ns debug-drill

# Create Deployment with label app=web-app
kubectl create deployment web-app --image=nginx:alpine --replicas=2 -n debug-drill

# Create Service with WRONG selector app=web-ap
kubectl create service clusterip web-access --tcp=80:80 -n debug-drill
kubectl patch service web-access -n debug-drill --type='json' -p='[{"op": "replace", "path": "/spec/selector", "value": {"app": "web-ap"}}]'

echo "Broken service created."
