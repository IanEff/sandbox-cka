#!/bin/bash
set -e

# Create Namespaces
kubectl create ns secure-backend --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns public-frontend --dry-run=client -o yaml | kubectl apply -f -

# Label namespaces (important for NetPol namespaceSelector)
kubectl label ns public-frontend role=frontend --overwrite
kubectl label ns secure-backend role=backend --overwrite

# Default Deny in secure-backend
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: secure-backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

# Backend DB
kubectl run db --image=redis:alpine -n secure-backend --labels=app=db
kubectl expose pod db --name=db-service --port=6379 -n secure-backend

# Frontend Web
kubectl run web --image=busybox -n public-frontend --labels=app=web -- sleep 3600
