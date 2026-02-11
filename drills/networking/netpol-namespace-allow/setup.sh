#!/bin/bash

# Clean up
kubectl delete ns backend frontend --ignore-not-found

# Create Namespaces
kubectl create ns backend
kubectl create ns frontend

# Label frontend namespace (crucial for namespaceSelector)
kubectl label ns frontend name=frontend

# Create Backend Pods
kubectl run backend-app --image=nginx:alpine -n backend --labels=app=backend

# Create Frontend Pods
kubectl run client-pod --image=busybox:1.28 -n frontend --labels=app=client -- sleep 3600
kubectl run other-pod --image=busybox:1.28 -n frontend --labels=app=other -- sleep 3600
