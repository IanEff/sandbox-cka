#!/bin/bash

# Clean up
kubectl delete deployment spread-deploy --ignore-not-found

# Create basic deployment WITHOUT topology spread constraints
kubectl create deployment spread-deploy --image=nginx:alpine --replicas=4
kubectl label deployment spread-deploy app=spread-app --overwrite

# Wait for rollout
kubectl rollout status deployment/spread-deploy
