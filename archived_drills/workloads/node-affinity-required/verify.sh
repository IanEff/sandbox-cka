#!/bin/bash
NS="affinity-test"

# 1. Check if any node has the label
if ! kubectl get nodes -l disk=ssd > /dev/null 2>&1; then
  echo "No nodes found with label 'disk=ssd'."
  exit 1
fi

# 2. Check Pod Status
# Wait for scheduling
if kubectl wait --for=condition=ready pod -l app=picky -n $NS --timeout=10s > /dev/null 2>&1; then
  echo "Pod is successfully scheduled and running."
  exit 0
else
  echo "Pod is not ready. Scheduling might still be failing."
  exit 1
fi
