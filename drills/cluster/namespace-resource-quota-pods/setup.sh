#!/bin/bash
# Setup for namespace-resource-quota-pods

kubectl create namespace quota-test --dry-run=client -o yaml | kubectl apply -f -
kubectl -n quota-test delete quota pod-limiter --ignore-not-found
