#!/bin/bash
BACKEND_IP=$(kubectl get pod backend -n secure-net -o jsonpath='{.status.podIP}')

# 1. Check if policy exists
if ! kubectl get netpol default-deny -n secure-net > /dev/null 2>&1; then
    echo "FAIL: NetworkPolicy default-deny not found"
    exit 1
fi

# 2. Check if traffic is blocked. timeout is crucial.
echo "Testing connectivity..."
if kubectl exec intruder -- timeout 3 wget -O- http://$BACKEND_IP > /dev/null 2>&1; then
    echo "FAIL: Traffic was allowed from intruder to backend."
    exit 1
else
    echo "SUCCESS: Connection timed out or failed as expected."
    exit 0
fi
