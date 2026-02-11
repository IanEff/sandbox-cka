#!/bin/bash

# Test DNS
kubectl exec arthur-dent -- nslookup kubernetes.default > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "SUCCESS: Arthur can understand the Vogon poetry (DNS works)."
    exit 0
else
    echo "FAIL: DNS resolution still failing."
    exit 1
fi
