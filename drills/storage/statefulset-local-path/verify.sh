#!/bin/bash

# Check StatefulSet
if ! kubectl get statefulset kv-store -n data &>/dev/null; then
  echo "ERROR: StatefulSet kv-store not found in data namespace"
  exit 1
fi

# Check Replicas
REPLICAS=$(kubectl get statefulset kv-store -n data -o jsonpath='{.spec.replicas}')
if [[ "$REPLICAS" -ne 2 ]]; then
  echo "ERROR: Expected 2 replicas, found $REPLICAS"
  exit 1
fi

# Check StorageClass in VolumeClaimTemplate
SC=$(kubectl get statefulset kv-store -n data -o jsonpath='{.spec.volumeClaimTemplates[0].spec.storageClassName}')
if [[ "$SC" != "local-path" ]]; then
  echo "ERROR: StorageClass is '$SC', expected 'local-path'"
  exit 1
fi

# Check PVCs are bound
if ! kubectl get pvc data-kv-store-0 -n data &>/dev/null; then
  echo "ERROR: PVC data-kv-store-0 not found"
  exit 1
fi

STATUS=$(kubectl get pvc data-kv-store-0 -n data -o jsonpath='{.status.phase}')
if [[ "$STATUS" != "Bound" ]]; then
  echo "ERROR: PVC data-kv-store-0 is $STATUS, expected Bound"
  exit 1
fi

echo "SUCCESS: StatefulSet using local-path storage is correctly configured"
exit 0
