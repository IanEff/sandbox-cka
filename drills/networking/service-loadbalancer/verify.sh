#!/bin/bash

# Check namespace
if ! kubectl get namespace public &>/dev/null; then
  echo "ERROR: Namespace public not found"
  exit 1
fi

# Check Deployment
if ! kubectl get deployment lb-app -n public &>/dev/null; then
  echo "ERROR: Deployment lb-app not found"
  exit 1
fi

# Check Service
if ! kubectl get service lb-service -n public &>/dev/null; then
  echo "ERROR: Service lb-service not found"
  exit 1
fi

# Check Service Type
TYPE=$(kubectl get service lb-service -n public -o jsonpath='{.spec.type}')
if [[ "$TYPE" != "LoadBalancer" ]]; then
  echo "ERROR: Service type is $TYPE, expected LoadBalancer"
  exit 1
fi

# Check External IP allocation (MetalLB)
# WaitFor external IP
timeout 10s bash -c 'until kubectl get service lb-service -n public -o jsonpath="{.status.loadBalancer.ingress[0].ip}" | grep -q "."; do sleep 1; done' || true

EXTERNAL_IP=$(kubectl get service lb-service -n public -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [[ -z "$EXTERNAL_IP" ]]; then
  echo "ERROR: Service has not received an External IP"
  exit 1
fi

echo "SUCCESS: Service exposed via LoadBalancer with IP: $EXTERNAL_IP"
exit 0
