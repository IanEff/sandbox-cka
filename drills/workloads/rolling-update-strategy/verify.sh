#!/bin/bash
set -e

# Check deployment exists
if ! kubectl get deployment web-app -n production &>/dev/null; then
    echo "❌ Deployment 'web-app' not found in production namespace"
    exit 1
fi

# Check image is updated
image=$(kubectl get deployment web-app -n production -o jsonpath='{.spec.template.spec.containers[0].image}')
if [ "$image" != "nginx:1.21" ]; then
    echo "❌ Deployment image is '$image', expected 'nginx:1.21'"
    exit 1
fi

# Check maxUnavailable
max_unavailable=$(kubectl get deployment web-app -n production -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}')
if [ "$max_unavailable" != "1" ]; then
    echo "❌ maxUnavailable is '$max_unavailable', expected '1'"
    exit 1
fi

# Check maxSurge
max_surge=$(kubectl get deployment web-app -n production -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}')
if [ "$max_surge" != "2" ]; then
    echo "❌ maxSurge is '$max_surge', expected '2'"
    exit 1
fi

# Check deployment is available
if ! kubectl wait --for=condition=available --timeout=30s deployment/web-app -n production &>/dev/null; then
    echo "❌ Deployment is not available"
    exit 1
fi

echo "✅ Deployment updated with correct rolling update strategy"
exit 0
