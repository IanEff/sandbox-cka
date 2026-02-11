#!/bin/bash
# Setup for deployment-rollback-revision

kubectl create namespace rollout-test --dry-run=client -o yaml | kubectl apply -f -

# Begin fresh
kubectl -n rollout-test delete deploy nginx-deploy --ignore-not-found

# Create Initial V1
kubectl -n rollout-test create deploy nginx-deploy --image=nginx:1.21 --replicas=2
# Wait for ready
kubectl -n rollout-test rollout status deploy/nginx-deploy
