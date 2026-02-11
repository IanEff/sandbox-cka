#!/bin/bash

# Uncordon first to be sure
kubectl uncordon ubukubu-node-1 --ignore-not-found

# Force scheduling on node-1
kubectl delete pod maintenance-test-pod --ignore-not-found

# Create a pod assigned to node-1
kubectl run maintenance-test-pod --image=nginx:alpine --overrides='{"spec": {"nodeName": "ubukubu-node-1"}}'

# Wait for it to be running
kubectl wait --for=condition=Ready pod/maintenance-test-pod --timeout=30s
