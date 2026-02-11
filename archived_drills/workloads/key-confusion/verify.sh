#!/bin/bash
set -e

echo "Checking secret injection..."

# Check if secret has correct keys
HAS_USERNAME=$(kubectl get secret db-credentials -n secrets-ns -o jsonpath='{.data.username}' 2>/dev/null || echo "")
HAS_PASSWORD=$(kubectl get secret db-credentials -n secrets-ns -o jsonpath='{.data.password}' 2>/dev/null || echo "")

# Check deployment is running
READY=$(kubectl get deployment api-server -n secrets-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
DESIRED=$(kubectl get deployment api-server -n secrets-ns -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")

echo "Secret has 'username' key: $([ -n "$HAS_USERNAME" ] && echo 'yes' || echo 'no')"
echo "Secret has 'password' key: $([ -n "$HAS_PASSWORD" ] && echo 'yes' || echo 'no')"
echo "Deployment ready: $READY/$DESIRED"

if [ -n "$HAS_USERNAME" ] && [ -n "$HAS_PASSWORD" ] && [ "$READY" = "$DESIRED" ]; then
    echo "SUCCESS: Secret keys correct and deployment running!"
    exit 0
else
    echo "FAIL: Secret/deployment not properly configured."
    [ -z "$HAS_USERNAME" ] && echo "  - Secret missing 'username' key"
    [ -z "$HAS_PASSWORD" ] && echo "  - Secret missing 'password' key"
    [ "$READY" != "$DESIRED" ] && echo "  - Deployment not ready ($READY/$DESIRED)"
    exit 1
fi
