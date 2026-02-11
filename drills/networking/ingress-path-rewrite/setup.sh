#!/bin/bash
# Setup for Ingress Drill

# Create distinct services
kubectl create deploy foo-app --image=nginx:alpine --replicas=1 --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deploy foo-app --name=svc-foo --port=80 --dry-run=client -o yaml | kubectl apply -f -

kubectl create deploy bar-app --image=httpd:alpine --replicas=1 --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deploy bar-app --name=svc-bar --port=80 --dry-run=client -o yaml | kubectl apply -f -
