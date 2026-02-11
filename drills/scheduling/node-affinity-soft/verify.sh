#!/bin/bash
set -e

# Verify Pod is running
if ! kubectl wait --for=condition=ready pod/preferred-pod --timeout=60s > /dev/null; then
    echo "FAIL: Pod 'preferred-pod' is not running."
    exit 1
fi

# Verify Affinity Rule
AFFINITY=$(kubectl get pod preferred-pod -o json)

# Check for preferredDuringSchedulingIgnoredDuringExecution
if ! echo "$AFFINITY" | grep -q "preferredDuringSchedulingIgnoredDuringExecution"; then
    echo "FAIL: Pod does not have preferred Node Affinity configured."
    exit 1
fi

# Check for label 'disk=ssd'
if ! echo "$AFFINITY" | grep -q "disk"; then
    echo "FAIL: Pod affinity does not reference label 'disk'."
    exit 1
fi

if ! echo "$AFFINITY" | grep -q "ssd"; then
    echo "FAIL: Pod affinity does not reference value 'ssd'."
    exit 1
fi

# Check for weight 50
if ! echo "$AFFINITY" | grep -q "\"weight\": 50"; then
    echo "FAIL: Pod affinity weight is not 50."
    exit 1
fi

echo "SUCCESS: Pod 'preferred-pod' has correct soft node affinity."
