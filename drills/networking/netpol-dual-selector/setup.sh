#!/bin/bash
# Setup for netpol-dual-selector

kubectl create namespace restricted-net --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl -n restricted-net delete netpol secure-access --ignore-not-found
