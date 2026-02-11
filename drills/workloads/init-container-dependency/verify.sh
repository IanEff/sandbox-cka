#!/bin/bash
# workloads/init-container-dependency/verify.sh

# 1. Check Service
if ! kubectl get svc mydb >/dev/null 2>&1; then
    echo "FAIL: Service 'mydb' not found."
    exit 1
fi

# 2. Check Pod Status
STATUS=$(kubectl get pod web-wait -o jsonpath='{.status.phase}')
if [ "$STATUS" != "Running" ]; then
    echo "FAIL: Pod is $STATUS (expected Running)."
    exit 1
fi

# 3. Check Init Container exists
INIT=$(kubectl get pod web-wait -o jsonpath='{.spec.initContainers[0].name}')
if [ -z "$INIT" ]; then
    echo "FAIL: No init container found."
    exit 1
fi

echo "SUCCESS: Pod running after dependency met."
