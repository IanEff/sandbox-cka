#!/bin/bash

# Check if Pod exists and is running
kubectl get pod logger -n workloads-1 | grep Running || exit 1

# Check if adapter container exists
kubectl get pod logger -n workloads-1 -o jsonpath='{.spec.containers[*].name}' | grep "adapter" || exit 1

# Check if adapter is streaming logs
# We look for the "processing transaction" string in the adapter's logs
timeout 5 kubectl logs logger -c adapter -n workloads-1 | grep "processing transaction" || exit 1
