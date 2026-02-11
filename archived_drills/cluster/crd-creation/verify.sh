#!/bin/bash
# Verify for crd-creation drill

if kubectl get crd backups.stable.example.com > /dev/null 2>&1; then
    echo "SUCCESS: CRD backups.stable.example.com exists."
    exit 0
else
    echo "FAILURE: CRD backups.stable.example.com not found."
    exit 1
fi
