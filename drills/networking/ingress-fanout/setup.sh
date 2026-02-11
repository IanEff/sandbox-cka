#!/bin/bash

# Cleanup
kubectl delete ingress shop-ingress --ignore-not-found
kubectl delete service products-svc checkout-svc --ignore-not-found
kubectl delete deployment products-deploy checkout-deploy --ignore-not-found

# Create backends
kubectl create deployment products-deploy --image=nginx:alpine --replicas=1
kubectl expose deployment products-deploy --name=products-svc --port=80

kubectl create deployment checkout-deploy --image=nginx:alpine --replicas=1
kubectl expose deployment checkout-deploy --name=checkout-svc --port=80

echo "Created services products-svc and checkout-svc."
