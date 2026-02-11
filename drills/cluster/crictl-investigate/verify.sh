#!/bin/bash
POD="mystery-pod"

# Get Expected ID via kubectl (Cheating, but used for verification)
# We need the ID of the container 'secret-container'
EXPECTED_ID=$(kubectl get pod $POD -n default -o jsonpath='{.status.containerStatuses[0].containerID}' | sed 's/containerd:\/\///')

if [[ -z "$EXPECTED_ID" ]]; then
  echo "FAIL: Could not determine expected Container ID"
  exit 1
fi

USER_ID=$(cat /opt/mystery-id.txt | tr -d '[:space:]')

if [[ "$USER_ID" == "$EXPECTED_ID" ]]; then
  echo "SUCCESS: ID matches."
  exit 0
else
  # Allow for short ID if it's reasonable length? No, usually heavy checks full ID.
  # But crictl ps often gives short ID.
  # Let's check if expected starts with user id
  if [[ "$EXPECTED_ID" == "$USER_ID"* ]]; then
      echo "SUCCESS: ID matches (short form accepted)."
      exit 0
  fi
  echo "FAIL: Expected $EXPECTED_ID, got $USER_ID"
  exit 1
fi
