#!/bin/bash
# Verify NetworkPolicy Drill
set -e

HOST="web-svc.restricted.svc.cluster.local"

echo "Testing access from 'trusted' namespace (Should SUCCEED)..."
# Using timeout 5 curl.
if kubectl run test-access --image=curlimages/curl --restart=Never -n trusted --rm -i -- -m 5 http://$HOST >/dev/null 2>&1; then
    echo "PASS: Trusted access allowed."
else
    echo "FAIL: Trusted access blocked."
    exit 1
fi

echo "Testing access from 'other' namespace (Should FAIL)..."
if kubectl run test-block --image=curlimages/curl --restart=Never -n other --rm -i -- -m 2 http://$HOST >/dev/null 2>&1; then
     echo "FAIL: Access from 'other' namespace was allowed (should be blocked)."
     exit 1
else
     echo "PASS: Access from 'other' namespace blocked."
fi

# Not testing intra-namespace unless specified.

echo "SUCCESS: NetworkPolicy correctly enforcing isolation."
