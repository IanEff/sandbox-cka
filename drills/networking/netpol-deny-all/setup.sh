#!/bin/bash
NS="security-lockdown"
kubectl create ns $NS --dry-run=client -o yaml | kubectl apply -f -

# Backend
kubectl run backend --image=nginx:alpine --labels="app=backend" -n $NS --port=80 --expose

# Frontend (Valid client)
kubectl run frontend --image=busybox:1.28 --labels="app=frontend" -n $NS -- sleep 3600

# Rogue (Invalid client)
kubectl run rogue --image=busybox:1.28 --labels="app=rogue" -n $NS -- sleep 3600

kubectl wait --for=condition=ready pod -l app=backend -n $NS --timeout=60s
