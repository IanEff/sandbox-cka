#!/bin/bash

# Check Endpoints
EPS=$(kubectl get endpoints updater-service -o jsonpath='{.subsets[*].addresses[*].ip}')

if [ -z "$EPS" ]; then
    echo "No endpoints found for updater-service."
    exit 1
fi

# Count endpoints (should be 2)
COUNT=$(echo $EPS | wc -w)
if [ "$COUNT" -lt 2 ]; then
    echo "Expected at least 2 endpoints, found $COUNT."
    exit 1
fi

echo "Service updater-service has endpoints: $EPS"
exit 0
