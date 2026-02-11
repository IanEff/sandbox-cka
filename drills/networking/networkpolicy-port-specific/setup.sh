#!/bin/bash
kubectl delete ns restricted-net --ignore-not-found
kubectl create ns restricted-net

# Create Database Pod (Redis lists on 6379)
kubectl run database --image=redis:alpine -n restricted-net -l app=database --expose --port=6379

# Create Client Pod
kubectl run client --image=curlimages/curl -n restricted-net -l app=client -- sleep 3600
kubectl wait --for=condition=ready pod -l app=database -n restricted-net
kubectl wait --for=condition=ready pod -l app=client -n restricted-net
