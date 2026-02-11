#!/bin/bash
NS="public-access"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Clean up if exists
kubectl delete deploy echo-server -n $NS --ignore-not-found
kubectl delete svc echo-nodeport -n $NS --ignore-not-found
