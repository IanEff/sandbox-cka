#!/bin/bash
# Verify for service-account-permissions drill

# Check permissions
if kubectl auth can-i list pods --as=system:serviceaccount:default:monitor | grep -q "yes"; then
    echo "Permissions check passed."
else
    echo "FAILURE: ServiceAccount 'monitor' cannot list pods."
    exit 1
fi

# Check Pod
if kubectl get pod monitor-pod -o jsonpath='{.spec.serviceAccountName}' | grep -q "monitor"; then
    echo "SUCCESS: Pod 'monitor-pod' is using ServiceAccount 'monitor'."
    exit 0
else
    echo "FAILURE: Pod 'monitor-pod' not using correct ServiceAccount or not found."
    exit 1
fi
