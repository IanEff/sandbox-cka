#!/bin/bash
set -e

# Verify Namespace
kubectl get ns hpa-behavior > /dev/null

# Verify Deployment exists and has requests
kubectl get deploy -n hpa-behavior php-apache > /dev/null
REQUESTS=$(kubectl get deploy -n hpa-behavior php-apache -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
if [[ "$REQUESTS" != "200m" ]]; then
  echo "FAIL: Deployment requests not set to 200m"
  exit 1
fi

# Verify HPA
STABILIZATION=$(kubectl get hpa -n hpa-behavior php-apache -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}')

if [[ "$STABILIZATION" != "60" ]]; then
  echo "FAIL: HPA scaleDown stabilizationWindowSeconds is '${STABILIZATION}', expected '60'"
  exit 1
fi

echo "SUCCESS: HPA configured with correct scaleDown behavior"
exit 0
