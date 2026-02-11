#!/bin/bash
kubectl create ns storage-3 --dry-run=client -o yaml | kubectl apply -f -
# Clean up if exists
kubectl delete pv manual-pv-3 --ignore-not-found
kubectl delete pvc manual-pvc-3 -n storage-3 --ignore-not-found
