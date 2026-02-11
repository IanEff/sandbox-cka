#!/bin/bash
set -e

EP_COUNT=$(kubectl get endpoints backend-svc -n endpoint-ns -o jsonpath='{range .subsets[*].addresses[*]}{.ip}{"\n"}{end}' 2>/dev/null | grep -c . || echo 0)

echo "Endpoint count: $EP_COUNT"

if [ "$EP_COUNT" -ge 2 ]; then
    echo "SUCCESS: Service backend-svc has $EP_COUNT endpoints."
    exit 0
else
    echo "FAIL: Service backend-svc has $EP_COUNT endpoints (expected 2+)."
    exit 1
fi
