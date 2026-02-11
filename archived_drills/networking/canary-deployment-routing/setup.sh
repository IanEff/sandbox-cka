#!/bin/bash
kubectl create ns canary-ns --dry-run=client -o yaml | kubectl apply -f -

# Cleanup
kubectl delete deployment app-v1 app-v2 -n canary-ns --ignore-not-found

# v1
kubectl create deployment app-v1 --image=nginx:alpine --replicas=2 -n canary-ns
kubectl label deployment app-v1 -n canary-ns app=canary ver=v1 --overwrite

# v2
kubectl create deployment app-v2 --image=httpd:alpine --replicas=2 -n canary-ns
kubectl label deployment app-v2 -n canary-ns app=canary ver=v2 --overwrite

# Service targeting only v1
kubectl create service clusterip canary-svc --tcp=80:80 -n canary-ns --dry-run=client -o yaml | kubectl apply -f -
# Patch selector to be specific to v1
kubectl patch svc canary-svc -n canary-ns --type='json' -p='[{"op": "replace", "path": "/spec/selector", "value": {"ver": "v1"}}]'
