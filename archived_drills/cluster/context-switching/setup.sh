#!/bin/bash
set -e

# Create a service account
kubectl create sa restricted-user --dry-run=client -o yaml | kubectl apply -f -

# Create a cluster role that allows listing pods but not nodes
kubectl create clusterrole restricted-role --verb=get,list,watch --resource=pods --dry-run=client -o yaml | kubectl apply -f -

# Bind the role
kubectl create clusterrolebinding restricted-binding --serviceaccount=default:restricted-user --clusterrole=restricted-role --dry-run=client -o yaml | kubectl apply -f -

# Create a token for the user (for K8s 1.24+)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: restricted-user-token
  annotations:
    kubernetes.io/service-account.name: restricted-user
type: kubernetes.io/service-account-token
EOF

# Get the token
TOKEN=$(kubectl get secret restricted-user-token -o jsonpath='{.data.token}' | base64 --decode)

# Configure the new context
kubectl config set-credentials restricted-user --token=$TOKEN
kubectl config set-context restricted --cluster=kubernetes --user=restricted-user --namespace=default

echo "Context 'restricted' created."
