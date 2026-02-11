#!/bin/bash
# Verify Ingress

INGRESS_NAME="minimal-ingress"

if ! kubectl get ingress $INGRESS_NAME > /dev/null 2>&1; then
    echo "FAIL: Ingress '$INGRESS_NAME' not found."
    exit 1
fi

DATA=$(kubectl get ingress $INGRESS_NAME -o json)

# Check Host
HOST=$(echo "$DATA" | jq -r '.spec.rules[0].host')
if [[ "$HOST" != "test.drill" ]]; then
    echo "FAIL: Host is '$HOST' (expected test.drill)"
    exit 1
fi

# Check Paths
# We expect at least two paths.
PATH0=$(echo "$DATA" | jq -r '.spec.rules[0].http.paths[] | select(.path=="/foo") | .backend.service.name')
PATH1=$(echo "$DATA" | jq -r '.spec.rules[0].http.paths[] | select(.path=="/bar") | .backend.service.name')

if [[ "$PATH0" != "svc-foo" ]]; then
    echo "FAIL: Path /foo routes to '$PATH0' (expected svc-foo)"
    exit 1
fi

if [[ "$PATH1" != "svc-bar" ]]; then
    echo "FAIL: Path /bar routes to '$PATH1' (expected svc-bar)"
    exit 1
fi

# Check Class
CLASS=$(echo "$DATA" | jq -r '.spec.ingressClassName')
if [[ "$CLASS" != "cilium" ]]; then
    echo "FAIL: ingressClassName is '$CLASS' (expected cilium)"
    exit 1
fi

echo "SUCCESS: Ingress configured correctly."
exit 0
