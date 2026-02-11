#!/bin/bash
# Verify for namespace-resource-quota-pods

NS="quota-test"
QUOTA="pod-limiter"

# Check hard limit
LIMIT=$(kubectl -n $NS get quota $QUOTA -o jsonpath='{.status.hard.pods}')

if [ "$LIMIT" != "2" ]; then
    echo "FAIL: Pod limit is '$LIMIT', expected '2'"
    exit 1
fi

echo "SUCCESS: ResourceQuota configured correctly."
