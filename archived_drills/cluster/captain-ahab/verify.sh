#!/bin/bash
set -e

echo "Checking Helm release..."

# Check Helm release status
RELEASE_STATUS=$(helm status metrics-app -n helm-ns -o json 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4 || echo "not-found")

# Check deployment is running
READY=$(kubectl get deployment metrics-app -n helm-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
DESIRED=$(kubectl get deployment metrics-app -n helm-ns -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")

echo "Helm release status: $RELEASE_STATUS"
echo "Deployment ready: $READY/$DESIRED"

if [ "$RELEASE_STATUS" = "deployed" ] && [ "$READY" = "$DESIRED" ] && [ "$READY" != "0" ]; then
    echo "SUCCESS: Helm release healthy and deployment running!"
    exit 0
else
    echo "FAIL: Helm release not properly fixed."
    [ "$RELEASE_STATUS" != "deployed" ] && echo "  - Release status is not 'deployed' (current: $RELEASE_STATUS)"
    [ "$READY" != "$DESIRED" ] && echo "  - Deployment not ready ($READY/$DESIRED)"
    exit 1
fi
