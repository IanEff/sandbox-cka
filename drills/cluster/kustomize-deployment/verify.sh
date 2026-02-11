#!/bin/bash
# cluster/kustomize-deployment/verify.sh

# 1. Check deployment exists
if ! kubectl get deployment loop-app > /dev/null 2>&1; then
    echo "FAIL: Deployment loop-app not found."
    exit 1
fi

# 2. Check Replicas (should be 3)
REPLICAS=$(kubectl get deployment loop-app -o jsonpath='{.spec.replicas}')
if [ "$REPLICAS" != "3" ]; then
    echo "FAIL: Expected 3 replicas, found $REPLICAS"
    exit 1
fi

# 3. Check Labels
LABEL=$(kubectl get deployment loop-app -o jsonpath='{.metadata.labels.env}')
if [ "$LABEL" != "prod" ]; then
    echo "FAIL: Expected 'env=prod' label on Deployment (found: $LABEL)"
    exit 1
fi

echo "SUCCESS: Kustomize overlay applied correctly."
