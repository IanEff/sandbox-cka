#!/bin/bash
set -e

# Test: Can we resolve my-svc.dns-test.svc.cluster.local from a test pod?
TEST_POD="dns-verify-$$"
kubectl run $TEST_POD --image=busybox:1.36 --restart=Never --rm -i --timeout=30s -- \
    nslookup my-svc.dns-test.svc.cluster.local 2>&1 | tee /tmp/dns-result.txt

if grep -q "Address" /tmp/dns-result.txt && ! grep -q "NXDOMAIN" /tmp/dns-result.txt; then
    echo "SUCCESS: DNS resolution for my-svc.dns-test.svc.cluster.local works!"
    exit 0
else
    echo "FAIL: Cannot resolve my-svc.dns-test.svc.cluster.local"
    exit 1
fi
