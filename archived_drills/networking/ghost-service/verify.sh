#!/bin/bash

# Check if Service has endpoints
ENDPOINTS=$(kubectl get endpoints phantom -n haunted -o jsonpath='{.subsets[*].addresses[*].ip}')

if [ -z "$ENDPOINTS" ]; then
    echo "FAIL: No endpoints found for Service phantom."
    exit 1
else
    # Count endpoints, should be 2
    COUNT=$(echo $ENDPOINTS | wc -w)
    echo "SUCCESS: Found $COUNT endpoints."
fi
