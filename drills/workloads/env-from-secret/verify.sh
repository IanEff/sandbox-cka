#!/bin/bash
# Verify for env-from-secret

POD="env-pod"

# 1. Check Secret Key Injection via ENV
# The robust way is to exec and print env.
ENV_OUT=$(kubectl exec $POD -- env)

if [[ "$ENV_OUT" != *"DB_HOST=sql.example.com"* ]]; then
    echo "FAIL: DB_HOST not found in environment."
    exit 1
fi

if [[ "$ENV_OUT" != *"DB_PORT=5432"* ]]; then
    echo "FAIL: DB_PORT not found in environment."
    exit 1
fi

# 2. Check Use of 'envFrom' in Spec
# We want to ensure they didn't manually map 'env' list.
IS_ENVFROM=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].envFrom}')

if [ -z "$IS_ENVFROM" ]; then
    echo "FAIL: 'envFrom' not used in Pod spec. Did you map keys individually?"
    exit 1
fi

echo "SUCCESS: Secret env vars injected correctly via envFrom."
