#!/bin/bash
NS="trouble-cm"

# Check CM has key
kubectl get cm app-config -n $NS -o jsonpath='{.data.db-url}' | grep -q "postgres"
if [ $? -ne 0 ]; then
    echo "FAIL: ConfigMap key 'db-url' missing or incorrect value"
    exit 1
fi

# Check Pod is running
# It might take a moment to recover from error, wait a bit
kubectl wait --for=condition=ready pod/app-pod -n $NS --timeout=45s
if [ $? -ne 0 ]; then
    echo "FAIL: Pod 'app-pod' is not ready"
    exit 1
fi

echo "Verification success"
exit 0
