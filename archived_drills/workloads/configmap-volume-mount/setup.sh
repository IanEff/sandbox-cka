#!/bin/bash
# Setup for configmap-volume-mount drill

# Cleanup
kubectl delete pod logger --force --grace-period=0 2>/dev/null || true
kubectl delete configmap log-conf 2>/dev/null || true

# Create ConfigMap
kubectl create configmap log-conf --from-literal=log.properties="level=debug"
