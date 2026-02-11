#!/bin/bash
# Setup for ingress-fanout drill

# Cleanup
kubectl delete ingress fanout 2>/dev/null || true
kubectl delete svc video-service stream-service 2>/dev/null || true
kubectl delete deployment video-app stream-app 2>/dev/null || true

# Create Backend Services
kubectl create deployment video-app --image=nginx --port=80
kubectl expose deployment video-app --name=video-service --port=80

kubectl create deployment stream-app --image=nginx --port=80
kubectl expose deployment stream-app --name=stream-service --port=80
