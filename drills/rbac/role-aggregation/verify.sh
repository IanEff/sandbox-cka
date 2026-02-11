#!/bin/bash
set -e

# Check Role Existence
kubectl get clusterrole aggregate-reader > /dev/null

# Check Aggregation Rule
SELECTOR=$(kubectl get clusterrole aggregate-reader -o jsonpath='{.aggregationRule.clusterRoleSelectors[0].matchLabels.rbac\.example\.com/aggregate-to-reader}')

if [[ "$SELECTOR" != "true" ]]; then
  echo "FAIL: Aggregation selector missing or incorrect."
  exit 1
fi

# Check Effective Rules
# We can check if it has rules populated by the controller manager
RULES_COUNT=$(kubectl get clusterrole aggregate-reader -o json | jq '.rules | length')

if [[ "$RULES_COUNT" -lt 2 ]]; then
  echo "FAIL: ClusterRole does not have aggregated rules. Found $RULES_COUNT rules. (Wait a moment if you just created it?)"
  exit 1
fi

echo "SUCCESS: ClusterRole aggregation functional."
exit 0
