#!/bin/bash

# Check Pod status
STATUS=$(kubectl get pod db-pod -n storage-issue -o jsonpath='{.status.phase}')
if [[ "$STATUS" != "Running" ]]; then
  echo "ERROR: Pod db-pod is $STATUS, expected Running"
  # Check if it's pending due to PVC
  echo "Events:"
  kubectl get events -n storage-issue --field-selector involvedObject.name=db-pod | tail -n 3
  exit 1
fi

# Check PVC status
PVC_STATUS=$(kubectl get pvc db-pvc -n storage-issue -o jsonpath='{.status.phase}')
if [[ "$PVC_STATUS" != "Bound" ]]; then
  echo "ERROR: PVC db-pvc is $PVC_STATUS, expected Bound"
  exit 1
fi

# Check StorageClass used (should be local-path or default if local-path is default)
SC=$(kubectl get pvc db-pvc -n storage-issue -o jsonpath='{.spec.storageClassName}')
if [[ "$SC" != "local-path" ]]; then
  echo "WARNING: StorageClass is $SC. Make sure this is a valid class."
fi

echo "SUCCESS: Pod is running and PVC is bound"
exit 0
