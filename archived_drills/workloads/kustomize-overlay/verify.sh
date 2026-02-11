#!/bin/bash
# Verify for kustomize-overlay drill

if kubectl get deployment prod-nginx -l env=prod; then
    echo "SUCCESS: Deployment 'prod-nginx' with label 'env=prod' found."
    exit 0
else
    echo "FAILURE: Deployment 'prod-nginx' with label 'env=prod' not found."
    exit 1
fi
