#!/bin/bash

# Verify Network Isolation Drill

TARGET="prod-web.k2-prod.svc.cluster.local"

echo "Verifying Access Control..."

# 1. Access from k2-qa (Should SUCCEED)
echo "Testing access from k2-qa (Expected: SUCCESS)..."
kubectl exec -n k2-qa qa-client -- wget -O- --timeout=2 http://$TARGET:80 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "FAIL: k2-qa could not access prod-web."
    exit 1
fi

# 2. Access from default (Should FAIL)
echo "Testing access from default (Expected: FAILURE)..."
kubectl exec -n default stranger -- wget -O- --timeout=2 http://$TARGET:80 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "FAIL: default namespace WAS ABLE to access prod-web (Should be blocked)."
    exit 1
fi

echo "SUCCESS: Network Isolation Verified!"
exit 0
