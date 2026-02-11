#!/bin/bash
# Verify for service-endpoints-missing

NS="debug-me"
SVC="web-service"

# 1. Check Service exists
if ! kubectl -n $NS get svc $SVC >/dev/null 2>&1; then
    echo "FAIL: Service $SVC not found"
    exit 1
fi

# 2. Check Endpoints
# Get number of addresses in subsets (using jsonpath count isn't always reliable if empty)
EPS=$(kubectl -n $NS get endpoints $SVC -o jsonpath='{.subsets[*].addresses[*].ip}')

if [ -z "$EPS" ]; then
    echo "FAIL: Service $SVC has no endpoints."
    exit 1
fi

# 3. Check Selector matches Deployment (optional, but good for diagnostics)
SELECTOR=$(kubectl -n $NS get svc $SVC -o jsonpath='{.spec.selector.app}')
if [ "$SELECTOR" != "web-app" ]; then
    # Technically they could change the Deployment label, but the prompt asked to fix the Service.
    echo "WARNING: Service selector is '$SELECTOR', expected 'web-app'. If endpoints are populated, this might still be valid if you changed the Deployment."
fi

echo "SUCCESS: Service endpoints found."
