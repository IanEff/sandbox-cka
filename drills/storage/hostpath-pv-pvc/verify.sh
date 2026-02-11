#!/bin/bash

# Check PV exists and properties
kubectl get pv manual-pv-3 || exit 1
kubectl get pv manual-pv-3 -o jsonpath='{.spec.storageClassName}' | grep "manual" || exit 1
kubectl get pv manual-pv-3 -o jsonpath='{.spec.capacity.storage}' | grep "500Mi" || exit 1

# Check PVC status
kubectl get pvc manual-pvc-3 -n storage-3 -o jsonpath='{.status.phase}' | grep "Bound" || exit 1
kubectl get pvc manual-pvc-3 -n storage-3 -o jsonpath='{.spec.volumeName}' | grep "manual-pv-3" || exit 1

# Check Pod Mount
kubectl get pod data-consumer -n storage-3 -o jsonpath='{.spec.volumes[*].persistentVolumeClaim.claimName}' | grep "manual-pvc-3" || exit 1
