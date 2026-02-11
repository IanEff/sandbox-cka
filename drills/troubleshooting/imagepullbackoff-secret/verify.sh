#!/bin/bash

# Check namespace exists
if ! kubectl get namespace apps &>/dev/null; then
  echo "ERROR: Namespace apps not found"
  exit 1
fi

# Check deployment exists
if ! kubectl get deployment private-app -n apps &>/dev/null; then
  echo "ERROR: Deployment private-app not found in apps namespace"
  exit 1
fi

# Wait for deployment to be ready
if ! kubectl wait --for=condition=available deployment/private-app -n apps --timeout=30s &>/dev/null; then
  echo "ERROR: Deployment private-app is not available"
  REPLICAS=$(kubectl get deployment private-app -n apps -o jsonpath='{.status.readyReplicas}')
  echo "Ready replicas: ${REPLICAS:-0}"
  
  # Check pod status for more details
  POD_STATUS=$(kubectl get pods -n apps -l app=private-app -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
  if [[ "$POD_STATUS" == "Pending" ]]; then
    echo "Pods are still Pending - check image pull status"
  fi
  exit 1
fi

# Verify at least one replica is running
READY_REPLICAS=$(kubectl get deployment private-app -n apps -o jsonpath='{.status.readyReplicas}')
if [[ "$READY_REPLICAS" -lt 1 ]]; then
  echo "ERROR: No ready replicas found"
  exit 1
fi

# Verify pod is actually running (not in ImagePullBackOff)
POD_PHASE=$(kubectl get pods -n apps -l app=private-app -o jsonpath='{.items[0].status.phase}')
if [[ "$POD_PHASE" != "Running" ]]; then
  echo "ERROR: Pod is not in Running phase (current: $POD_PHASE)"
  exit 1
fi

# Check that image was successfully pulled
IMAGE_READY=$(kubectl get pods -n apps -l app=private-app -o jsonpath='{.items[0].status.containerStatuses[0].ready}')
if [[ "$IMAGE_READY" != "true" ]]; then
  echo "ERROR: Container is not ready"
  exit 1
fi

echo "SUCCESS: Deployment is running successfully with image pulled"
exit 0
