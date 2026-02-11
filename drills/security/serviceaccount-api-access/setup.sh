#!/bin/bash
kubectl delete ns security-drill --ignore-not-found
kubectl create ns security-drill

# Create SA
kubectl create sa api-reader -n security-drill

# Create Role
kubectl create role pod-reader --verb=list,get --resource=pods -n security-drill

# Create Binding
kubectl create rolebinding read-pods --role=pod-reader --serviceaccount=security-drill:api-reader -n security-drill

# Create Pod
# using image that has shell and curl. curlimages/curl has sh.
kubectl run api-client --image=curlimages/curl -n security-drill --overrides='{ "spec": { "serviceAccountName": "api-reader" } }' -- sleep 3600

kubectl wait --for=condition=ready pod api-client -n security-drill
