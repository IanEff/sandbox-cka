#!/bin/bash
set -e

# Break the scheduler by moving its manifest
# This simulates a "crash" or misconfiguration where the scheduler pod disappears
if [ -f /etc/kubernetes/manifests/kube-scheduler.yaml ]; then
    mv /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/kube-scheduler.yaml.bak
fi

# Create a pending pod
kubectl run test-pod --image=nginx:alpine --restart=Never > /dev/null 2>&1 || true

# Wait a moment to ensure it stays pending (it will, because scheduler is gone)
sleep 2
