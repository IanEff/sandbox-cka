#!/bin/bash

# Ensure namespace exists
kubectl create ns drill-gateway --dry-run=client -o yaml | kubectl apply -f -

# Deploy v1 (Nginx)
kubectl create deployment v1 --image=nginx:alpine --replicas=1 -n drill-gateway --dry-run=client -o yaml | kubectl apply -f -
kubectl create service clusterip v1 --tcp=80:80 -n drill-gateway --dry-run=client -o yaml | kubectl apply -f -

# Deploy v2 (Apache/httpd)
kubectl create deployment v2 --image=httpd:alpine --replicas=1 -n drill-gateway --dry-run=client -o yaml | kubectl apply -f -
kubectl create service clusterip v2 --tcp=80:80 -n drill-gateway --dry-run=client -o yaml | kubectl apply -f -

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=v1 -n drill-gateway --timeout=60s
kubectl wait --for=condition=ready pod -l app=v2 -n drill-gateway --timeout=60s

echo "Setup complete. Workloads 'v1' and 'v2' are ready in namespace 'drill-gateway'."
