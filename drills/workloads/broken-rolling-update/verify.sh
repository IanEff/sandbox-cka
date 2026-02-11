#!/bin/bash
# Check if image is NOT nginx:1.300
CURRENT_IMAGE=$(kubectl get deployment web-app -n workloads-drill -o jsonpath='{.spec.template.spec.containers[0].image}')
if [[ "$CURRENT_IMAGE" == *"1.300"* ]]; then
  echo "FAIL: Still using bad image $CURRENT_IMAGE"
  exit 1
fi

kubectl wait --for=condition=available deployment/web-app -n workloads-drill --timeout=10s
if [ $? -eq 0 ]; then
    echo "SUCCESS: Deployment is available."
    exit 0
else
    echo "FAIL: Deployment is not available."
    exit 1
fi
