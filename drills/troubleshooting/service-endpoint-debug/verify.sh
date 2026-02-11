#!/bin/bash

# Check if Service has endpoints
ENDPOINTS=$(kubectl get endpoints frontend-svc -n troubleshooting-5 -o jsonpath='{.subsets[*].addresses[*].ip}')

if [ -z "$ENDPOINTS" ]; then
  echo "FAIL: No endpoints found for frontend-svc"
  exit 1
fi

echo "SUCCESS: Endpoints found: $ENDPOINTS"
exit 0
