#!/bin/bash
# workloads/security-context-capabilities/verify.sh

# 1. Check Pod Running
if ! kubectl get pod secure-cap >/dev/null 2>&1; then
    echo "FAIL: Pod 'secure-cap' not found."
    exit 1
fi

# 2. Check Added Cap
ADDED=$(kubectl get pod secure-cap -o jsonpath='{.spec.containers[0].securityContext.capabilities.add}')
if [[ "$ADDED" != *"NET_ADMIN"* ]]; then
    echo "FAIL: NET_ADMIN not found in added capabilities."
    exit 1
fi

# 3. Check Dropped Cap
DROPPED=$(kubectl get pod secure-cap -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop}')
if [[ "$DROPPED" != *"ALL"* ]]; then
    echo "FAIL: 'ALL' not found in dropped capabilities."
    exit 1
fi

echo "SUCCESS: Capabilities configured correctly."
