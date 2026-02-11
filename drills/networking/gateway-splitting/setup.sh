#!/bin/bash
kubectl delete ns gateway-drill --ignore-not-found
kubectl create ns gateway-drill

# Create Blue App
kubectl run blue --image=nginx:alpine --restart=Never -n gateway-drill --labels="app=blue"
kubectl create service clusterip blue --tcp=80:80 -n gateway-drill

# Create Green App
kubectl run green --image=nginx:alpine --restart=Never -n gateway-drill --labels="app=green"
kubectl create service clusterip green --tcp=80:80 -n gateway-drill

echo "Waiting for pods..."
kubectl wait --for=condition=ready pod -l app=blue -n gateway-drill --timeout=60s
kubectl wait --for=condition=ready pod -l app=green -n gateway-drill --timeout=60s
