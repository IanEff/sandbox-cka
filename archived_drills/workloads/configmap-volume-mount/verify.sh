#!/bin/bash
# Verify for configmap-volume-mount drill

if kubectl get pod logger | grep -q "Running"; then
    if kubectl exec logger -- cat /etc/config/log.properties | grep -q "level=debug"; then
        echo "SUCCESS: Pod is running and ConfigMap is mounted correctly."
        exit 0
    fi
fi

echo "FAILURE: Pod is not running or ConfigMap not mounted/content incorrect."
exit 1
