#!/bin/bash
NS="logging"
POD="logger-app"

# Check sidecar exists
SIDECAR_IMG=$(kubectl get pod $POD -n $NS -o jsonpath='{.spec.containers[?(@.name=="log-adapter")].image}')
if [[ -z "$SIDECAR_IMG" ]]; then
  echo "FAIL: Sidecar container 'log-adapter' not found"
  exit 1
fi

# Check logs from sidecar
# We expect "System OK" in the output
if ! kubectl logs $POD -c log-adapter -n $NS --tail=10 | grep -q "System OK"; then
  echo "FAIL: Sidecar logs do not contain expected output."
  exit 1
fi

echo "SUCCESS: Sidecar is streaming logs."
exit 0
