#!/bin/bash
# Setup for HPA Drill
# Uses the classic php-apache image for easy CPU stress testing

kubectl create deployment hpa-behavior-deploy \
    --image=registry.k8s.io/hpa-example \
    --replicas=1 \
    --port=80 \
    --dry-run=client -o yaml | kubectl apply -f -

# Set resources so HPA can calculate CPU%
kubectl set resources deployment hpa-behavior-deploy --requests=cpu=200m

# Create service (just in case they need it, though HPA works on Deployment)
kubectl expose deployment hpa-behavior-deploy --port=80 --dry-run=client -o yaml | kubectl apply -f -
