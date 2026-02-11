#!/bin/bash
# networking/gateway-path-routing/setup.sh

# Deploy v1 service
kubectl create deployment echo-v1 --image=nginx:alpine --replicas=1 --dry-run=client -o yaml | kubectl apply -f -
kubectl create service clusterip echo-v1 --tcp=80:80 --dry-run=client -o yaml | kubectl apply -f -

# Deploy v2 service
kubectl create deployment echo-v2 --image=nginx:alpine --replicas=1 --dry-run=client -o yaml | kubectl apply -f -
kubectl create service clusterip echo-v2 --tcp=80:80 --dry-run=client -o yaml | kubectl apply -f -

# Clean up older gateway stuff if exists
kubectl delete gateway my-gateway 2>/dev/null || true
kubectl delete httproute echo-route 2>/dev/null || true
