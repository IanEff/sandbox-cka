#!/bin/bash
# Setup for service-session-affinity

kubectl create namespace sticky-session --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl -n sticky-session delete svc backend-svc --ignore-not-found
kubectl -n sticky-session delete deployment backend --ignore-not-found
