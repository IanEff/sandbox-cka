#!/bin/bash

# Verify Kustomize Drill

echo "Verifying Kustomize Drill..."

# 1. Check Namespace
kubectl get ns k2-prod > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "FAIL: Namespace k2-prod not found"
    exit 1
fi

# 2. Check Deployment Replicas
REPLICAS=$(kubectl get deploy -n k2-prod web-app -o jsonpath='{.spec.replicas}')
if [ "$REPLICAS" != "4" ]; then
    echo "FAIL: Expected 4 replicas, got $REPLICAS"
    exit 1
fi

# 3. Check Image
IMAGE=$(kubectl get deploy -n k2-prod web-app -o jsonpath='{.spec.template.spec.containers[0].image}')
if [ "$IMAGE" != "nginx:1.25" ]; then
    echo "FAIL: Expected image nginx:1.25, got $IMAGE"
    exit 1
fi

# 4. Check Labels
LABEL_ENV=$(kubectl get deploy -n k2-prod web-app -o jsonpath='{.metadata.labels.env}')
if [ "$LABEL_ENV" != "prod" ]; then
    echo "FAIL: Expected label env=prod, got $LABEL_ENV"
    exit 1
fi

echo "SUCCESS: Kustomize Overlay Drill Verified!"
exit 0
