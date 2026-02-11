#!/bin/bash
# Setup for context-namespace-switch

kubectl create namespace science --dry-run=client -o yaml | kubectl apply -f -
# Delete context if exists
kubectl config delete-context research --ignore-not-found
# Ensure we are on default or something standard
kubectl config use-context kubernetes-admin@kubernetes || true
