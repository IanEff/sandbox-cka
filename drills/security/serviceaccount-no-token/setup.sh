#!/bin/bash
set -e

# Create namespace
kubectl create ns security --dry-run=client -o yaml | kubectl apply -f -

# Ensure clean slate
kubectl delete sa no-token-sa -n security --ignore-not-found
kubectl delete pod secure-pod -n security --ignore-not-found
