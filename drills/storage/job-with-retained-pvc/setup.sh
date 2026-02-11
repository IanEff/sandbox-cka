#!/bin/bash
# Setup for Storage Backup Job Drill
set -e

# Cleanup
kubectl delete ns backup-system --ignore-not-found=true --wait=true
kubectl delete storageclass backup-storage --ignore-not-found=true

# Create namespace
kubectl create ns backup-system

echo "Setup complete."
echo "Create StorageClass 'backup-storage' with Retain policy"
echo "Create PVC 'backup-pvc' and Job 'backup-job' in namespace 'backup-system'"
