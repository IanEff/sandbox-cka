#!/bin/bash
# Setup for pod-interaction-copy

kubectl delete pod data-collector --ignore-not-found
kubectl run data-collector --image=nginx:alpine --restart=Never
# Wait for running
kubectl wait --for=condition=Ready pod/data-collector --timeout=30s
