#!/bin/bash
set -e

# Verify test-pod is running
if kubectl wait --for=condition=ready pod/test-pod --timeout=60s; then
    echo "SUCCESS: Pod 'test-pod' is running."
else
    echo "FAIL: Pod 'test-pod' did not become ready."
    exit 1
fi

# Verify scheduler manifest is back (best practice check, though pod running confirms it works)
if [ ! -f /etc/kubernetes/manifests/kube-scheduler.yaml ]; then
    echo "WARNING: Scheduler manifest not found in expected location, but Pod scheduled. Did you start it manually?"
fi
