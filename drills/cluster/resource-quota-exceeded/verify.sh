#!/bin/bash
NS="quota-land"

# 1. Check Deployment status
READY=$(kubectl get deploy bloated-app -n $NS -o jsonpath='{.status.readyReplicas}')
if [[ "$READY" != "1" ]]; then
  echo "Deployment 'bloated-app' is not ready (Ready Replicas: ${READY:-0})."
  exit 1
fi

# 2. Check CPU Request
CPU_REQ=$(kubectl get kv pod -n $NS -l app=bloated -o jsonpath='{.items[0].spec.containers[0].resources.requests.cpu}')

# Helper function to convert millicores if needed (simple check for now)
if [[ "$CPU_REQ" == "1" ]]; then
  echo "CPU request is still '1'. It needs to be reduced."
  exit 1
fi

echo "Pod is running and quota is satisfied."
exit 0
