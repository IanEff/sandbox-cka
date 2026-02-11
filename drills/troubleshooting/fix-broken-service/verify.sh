#!/bin/bash
NS="debug-drill"

# Check endpoints
ENDPOINTS=$(kubectl get endpoints web-access -n $NS -o jsonpath='{.subsets[*].addresses[*].ip}')

if [[ -z "$ENDPOINTS" ]]; then
  echo "Service has no endpoints."
  exit 1
fi

echo "Service endpoints found: $ENDPOINTS"
exit 0
