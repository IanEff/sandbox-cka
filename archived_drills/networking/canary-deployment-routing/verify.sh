#!/bin/bash
# Check if service selector matches common label
SELECTOR=$(kubectl get svc canary-svc -n canary-ns -o jsonpath='{.spec.selector}')
echo "Current Selector: $SELECTOR"

# We expect the selector to NOT contain "ver": "v1" or "ver": "v2", 
# but likely "app": "canary" (or just common labels).
# STRICT CHECK: Selector should match both deployments.

# Check endpoints
EP_COUNT=$(kubectl get endpoints canary-svc -n canary-ns -o jsonpath='{range .subsets[*].addresses[*]}{.ip}{"\n"}{end}' | wc -l)
echo "Endpoint Count: $EP_COUNT"

# We have 2 replicas of v1 and 2 replicas of v2. Total 4.
if [ "$EP_COUNT" -eq 4 ]; then
    echo "SUCCESS: Service is routing to all 4 pods."
    exit 0
else
    echo "FAIL: Endpoint count is $EP_COUNT (expected 4)."
    exit 1
fi
