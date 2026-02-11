#!/bin/bash
NS="hardware-ops"
POD_LABEL="app=ssd-app"

# 1. Check if ANY node has the label
count=$(kubectl get nodes -l disktype=ssd --no-headers | wc -l)
if [ "$count" -eq 0 ]; then
    echo "FAIL: No nodes found with label disktype=ssd"
    exit 1
fi

# 2. Check if Pod is Running
# Using kubectl wait
kubectl wait --for=condition=ready pod -l $POD_LABEL -n $NS --timeout=10s
if [ $? -ne 0 ]; then
    echo "FAIL: Pod is not in Ready state (Scheduling issue persists?)"
    exit 1
fi

echo "Verification success"
exit 0
