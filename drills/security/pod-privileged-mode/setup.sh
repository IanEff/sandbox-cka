#!/bin/bash
# Setup for pod-privileged-mode

kubectl create namespace security-zone --dry-run=client -o yaml | kubectl apply -f -
kubectl -n security-zone delete pod root-access --ignore-not-found
