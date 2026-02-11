#!/bin/bash
kubectl delete pod backend-pod --ignore-not-found
kubectl delete svc broken-svc --ignore-not-found

kubectl run backend-pod --image=nginx:alpine --labels="app=backend"
kubectl expose pod backend-pod --name=broken-svc --port=80 --dry-run=client -o yaml | \
  sed 's/app: backend/app: frontend/' | kubectl apply -f -
