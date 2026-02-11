#!/bin/bash
# Check if pod is running
# Note: Static pods created by kubelet on node X are named <pod-name>-<node-name>
POD_NAME="control-monitor-ubukubu-control"

if kubectl get pod "$POD_NAME" -n default 2>/dev/null | grep -q Running; then
    echo "SUCCESS: Static pod is running."
    exit 0
else
    # Check if maybe they renamed it or something (unlikely given it's a static pod fix)
    echo "FAIL: Pod $POD_NAME not found or not running."
    
    # Check if the file still has the typo
    if grep -q "imagee:" /etc/kubernetes/manifests/control-monitor.yaml 2>/dev/null; then
         echo "Diagnose: Typo 'imagee' still present in manifest."
    fi
    exit 1
fi
