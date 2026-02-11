#!/bin/bash

# Setup for Network Isolation Drill

# 1. Clean up
kubectl delete ns k2-prod k2-qa --ignore-not-found
kubectl delete pod stranger --ignore-not-found

# 2. Create Namespaces
kubectl create ns k2-prod
kubectl label ns k2-prod env=prod
kubectl create ns k2-qa
kubectl label ns k2-qa env=qa

# 3. Create Resources in k2-prod
kubectl run prod-web --image=nginx --restart=Never -n k2-prod --labels=app=web
kubectl expose pod prod-web --port=80 --name=prod-web -n k2-prod

# 4. Create Resources in k2-qa
kubectl run qa-client --image=busybox --restart=Never -n k2-qa -- sleep 3600

# 5. Create Resources in default
kubectl run stranger --image=busybox --restart=Never -- sleep 3600

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pod/prod-web -n k2-prod --timeout=60s
kubectl wait --for=condition=Ready pod/qa-client -n k2-qa --timeout=60s
kubectl wait --for=condition=Ready pod/stranger -n default --timeout=60s

echo "Setup complete. Namespace k2-prod is ready for lockdown."
