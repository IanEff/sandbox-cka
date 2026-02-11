#!/bin/bash
# Clean
kubectl delete clusterrole aggregate-reader --ignore-not-found
kubectl delete clusterrole cr-reader-1 --ignore-not-found
kubectl delete clusterrole cr-reader-2 --ignore-not-found

# Setup component roles
kubectl create clusterrole cr-reader-1 --verb=get,list --resource=pods --dry-run=client -o yaml | kubectl apply -f -
kubectl label clusterrole cr-reader-1 rbac.example.com/aggregate-to-reader="true" --overwrite

kubectl create clusterrole cr-reader-2 --verb=get,list --resource=services --dry-run=client -o yaml | kubectl apply -f -
kubectl label clusterrole cr-reader-2 rbac.example.com/aggregate-to-reader="true" --overwrite
