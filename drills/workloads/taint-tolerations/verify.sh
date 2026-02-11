#!/bin/bash

# Check namespace exists
if ! kubectl get namespace monitoring &>/dev/null; then
  echo "ERROR: Namespace monitoring not found"
  exit 1
fi

# Check pod exists
if ! kubectl get pod monitor-agent -n monitoring &>/dev/null; then
  echo "ERROR: Pod monitor-agent not found in monitoring namespace"
  exit 1
fi

# Wait for pod to be running
if ! kubectl wait --for=condition=ready pod/monitor-agent -n monitoring --timeout=30s &>/dev/null; then
  echo "ERROR: Pod monitor-agent is not Ready"
  POD_STATUS=$(kubectl get pod monitor-agent -n monitoring -o jsonpath='{.status.phase}')
  echo "Current status: $POD_STATUS"
  exit 1
fi

# Verify pod is scheduled on a node (not pending)
NODE_NAME=$(kubectl get pod monitor-agent -n monitoring -o jsonpath='{.spec.nodeName}')
if [[ -z "$NODE_NAME" ]]; then
  echo "ERROR: Pod is not scheduled on any node"
  exit 1
fi

# Verify the node has the taint
if ! kubectl get node "$NODE_NAME" -o jsonpath='{.spec.taints[?(@.key=="monitoring")]}' | grep -q "monitoring"; then
  echo "ERROR: Pod is not running on the tainted node"
  exit 1
fi

# Verify pod has toleration for the taint
if ! kubectl get pod monitor-agent -n monitoring -o yaml | grep -q "monitoring"; then
  echo "ERROR: Pod does not have proper toleration"
  exit 1
fi

echo "SUCCESS: Pod monitor-agent is running on tainted node $NODE_NAME"
exit 0
