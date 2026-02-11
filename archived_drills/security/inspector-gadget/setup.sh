#!/bin/bash
kubectl create ns go-go --dry-run=client -o yaml | kubectl apply -f -

# Cleanup
kubectl delete sa gadget-sa -n go-go --ignore-not-found
kubectl delete role secret-inspector -n go-go --ignore-not-found
kubectl delete rolebinding gadget-binding -n go-go --ignore-not-found
kubectl delete pod gadget-pod -n go-go --ignore-not-found

# Create SA
kubectl create sa gadget-sa -n go-go

# Create Role that PERMITS listing secrets, but don't bind it? Or bind a role that doesn't permit it?
# Let's bind it to a role that permits 'get' but not 'list'.
# The task says "can list secrets".

kubectl create role secret-inspector --verb=get --resource=secrets -n go-go
kubectl create rolebinding gadget-binding --role=secret-inspector --serviceaccount=go-go:gadget-sa -n go-go

# Check Pod
# We'll create a pod that tries to list secrets.
kubectl run gadget-pod --image=bitnami/kubectl -n go-go --overrides='{"spec": {"serviceAccountName": "gadget-sa", "nodeSelector": {"kubernetes.io/hostname": "ubukubu-node-1"}}}' --command -- sleep 3600
