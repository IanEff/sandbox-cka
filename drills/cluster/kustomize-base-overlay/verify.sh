#!/bin/bash
# Verify for kustomize-base-overlay

# Check Namespace
kubectl get ns prod-ns >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Namespace prod-ns not found"
    exit 1
fi

# Check Deployment in NS
replicas=$(kubectl get deploy app -n prod-ns -o jsonpath='{.spec.replicas}')
if [ "$replicas" != "2" ]; then
    echo "Expected 2 replicas, found $replicas"
    exit 1
fi

# Check Labels
labels=$(kubectl get deploy app -n prod-ns -o jsonpath='{.metadata.labels.variant}')
if [ "$labels" != "production" ]; then
    echo "Expected label variant: production, found $labels"
    exit 1
fi

echo "Passed kustomize drill"
exit 0
