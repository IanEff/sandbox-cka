#!/bin/bash
# Verify Pod Affinity Drill
set -e

# Check Deployment Exists
if ! kubectl get deploy redis-cache >/dev/null 2>&1; then
    echo "FAIL: Deployment 'redis-cache' not found."
    exit 1
fi

# Check Replicas Ready
kubectl wait --for=condition=available deploy/redis-cache --timeout=60s

# Get Node of backend-app
BACKEND_NODE=$(kubectl get pod backend-app -o jsonpath='{.spec.nodeName}')

# Get Nodes of redis-cache pods
# Check by deployment selector first
SELECTOR=$(kubectl get deploy redis-cache -o jsonpath='{.spec.selector.matchLabels}' | jq -r 'to_entries | map("\(.key)=\(.value)") | join(",")')

# If jq fails or selector empty, use name grep as fallback
if [ -z "$SELECTOR" ]; then
    echo "WARNING: Could not parse selector. Falling back to name match."
    PODS=$(kubectl get pods -o name | grep redis-cache | cut -d/ -f2)
else
    PODS=$(kubectl get pods -l "$SELECTOR" -o jsonpath='{.items[*].metadata.name}')
fi

if [ -z "$PODS" ]; then
    echo "FAIL: No pods found for redis-cache."
    exit 1
fi

for POD in $PODS; do
    NODE=$(kubectl get pod $POD -o jsonpath='{.spec.nodeName}')
    if [ "$NODE" != "$BACKEND_NODE" ]; then
        echo "FAIL: Pod $POD is on node $NODE, but backend is on $BACKEND_NODE."
        exit 1
    fi
done

# Check Spec contains 'podAffinity'
HAS_AFFINITY=$(kubectl get deploy redis-cache -o jsonpath='{.spec.template.spec.affinity.podAffinity}')
if [ -z "$HAS_AFFINITY" ]; then
    echo "FAIL: No podAffinity found in deployment spec."
    exit 1
fi

echo "SUCCESS: Redis pods are co-located with backend-app."
