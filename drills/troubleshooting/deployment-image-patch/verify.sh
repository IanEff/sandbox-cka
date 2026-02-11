#!/bin/bash
IMAGE=$(kubectl get deploy backend-api -o jsonpath='{.spec.template.spec.containers[0].image}')
if [[ "$IMAGE" != "nginx:1.19" ]]; then echo "Wrong image: $IMAGE"; exit 1; fi

# Ensure the rollout actually succeeded
if ! kubectl rollout status deploy/backend-api --timeout=10s; then
    echo "Deployment is not stable/ready"
    exit 1
fi
