#!/bin/bash
# Setup for netpol-ingress-namespace

kubectl create namespace secure-app --dry-run=client -o yaml | kubectl apply -f -
kubectl -n secure-app delete netpol allow-trusted-ns --ignore-not-found
