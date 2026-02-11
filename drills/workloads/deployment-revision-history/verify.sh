#!/bin/bash
set -e
NS="history-limit"

# Check Deployment
kubectl get deploy clean-history -n $NS > /dev/null

# Check limit
LIMIT=$(kubectl get deploy clean-history -n $NS -o jsonpath='{.spec.revisionHistoryLimit}')

if [[ "$LIMIT" != "2" ]]; then
  echo "FAIL: revisionHistoryLimit is '$LIMIT'. Expected '2'."
  exit 1
fi

echo "SUCCESS: Revision history limit configured correctly."
exit 0
