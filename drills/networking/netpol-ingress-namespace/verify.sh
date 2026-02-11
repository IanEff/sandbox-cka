#!/bin/bash
# Verify for netpol-ingress-namespace

NS="secure-app"
NP="allow-trusted-ns"

# Check Namespace Selector
MATCH=$(kubectl -n $NS get netpol $NP -o jsonpath='{.spec.ingress[0].from[0].namespaceSelector.matchLabels.project}')

if [ "$MATCH" != "trusted" ]; then
    echo "FAIL: namespaceSelector does not match project=trusted (found: '$MATCH')"
    exit 1
fi

echo "SUCCESS: NetworkPolicy Ingress configured."
