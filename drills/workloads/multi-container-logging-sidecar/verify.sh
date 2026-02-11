#!/bin/bash
# Check if pod has 2 containers
COUNT=$(kubectl get pod log-pod -o jsonpath='{.spec.containers[*].name}' | wc -w)
if [[ "$COUNT" -lt 2 ]]; then
    echo "Pod does not have 2 containers"
    exit 1
fi

# Check if sidecar logs produce date
if kubectl logs log-pod -c sidecar | grep -q "UTC"; then
    exit 0
else
    echo "Sidecar logs empty or incorrect"
    exit 1
fi
