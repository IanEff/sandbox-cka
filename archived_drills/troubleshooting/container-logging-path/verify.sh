#!/bin/bash
NS="trouble-logs"
POD="logger"

# 1. Check if Pod exists
if ! kubectl get pod $POD -n $NS > /dev/null 2>&1; then
  echo "Pod '$POD' not found in namespace '$NS'."
  exit 1
fi

# 2. Check if Pod is running
STATUS=$(kubectl get pod $POD -n $NS -o jsonpath='{.status.phase}')
if [[ "$STATUS" != "Running" ]]; then
  echo "Pod '$POD' is not running (Status: $STATUS)."
  exit 1
fi

# 3. Check logs
LOG_CONTENT=$(kubectl logs $POD -n $NS --tail=20)
if echo "$LOG_CONTENT" | grep -q "System operational"; then
  echo "Logs detected in stdout! Success."
  exit 0
else
  echo "No expected logs found in stdout. Current logs:"
  echo "$LOG_CONTENT"
  exit 1
fi
