#!/bin/bash
NS="sci-storage"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Clean up any potential conflicts from previous runs
kubectl delete pv sci-pv --ignore-not-found
