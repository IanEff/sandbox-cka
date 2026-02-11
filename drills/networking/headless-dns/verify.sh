#!/bin/bash
set -e
NS="headless"

# Check Service
kubectl get svc goku -n $NS > /dev/null

# Check Headless
CLUSTER_IP=$(kubectl get svc goku -n $NS -o jsonpath='{.spec.clusterIP}')
if [[ "$CLUSTER_IP" != "None" ]]; then
  echo "FAIL: Service ClusterIP is '$CLUSTER_IP'. Expected 'None'."
  exit 1
fi

# Check Endpoints (Wait for deployment)
kubectl wait --for=condition=available deploy goku -n $NS --timeout=30s > /dev/null

EP_COUNT=$(kubectl get endpoints goku -n $NS -o jsonpath='{.subsets[0].addresses[*].ip}' | wc -w)
if [[ "$EP_COUNT" -lt 2 ]]; then
  echo "FAIL: Expected at least 2 endpoints for the headless service, found $EP_COUNT."
  # Debug
  kubectl get endpoints goku -n $NS
  exit 1
fi

echo "SUCCESS: Headless service configured correctly."
exit 0
