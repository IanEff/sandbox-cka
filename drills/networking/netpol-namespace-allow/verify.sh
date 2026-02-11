#!/bin/bash

# 1. Check if NetPol exists
if ! kubectl get netpol allow-client -n backend > /dev/null 2>&1; then
    echo "FAIL: NetworkPolicy 'allow-client' not found in namespace 'backend'."
    exit 1
fi

# 2. Check Namespace Selector
NS_SEL=$(kubectl get netpol allow-client -n backend -o jsonpath='{.spec.ingress[0].from[0].namespaceSelector.matchLabels.name}')
if [ "$NS_SEL" != "frontend" ]; then
    # It might use empty selector {} to select 'any namespace' but problem said 'in frontend namespace'.
    # Usually we match label 'name=frontend' or just verify they used namespaceSelector.
    # If they used namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: frontend}} that's also valid.
    
    # Try more generic check
    RAW=$(kubectl get netpol allow-client -n backend -o json)
    if [[ "$RAW" != *"namespaceSelector"* ]]; then
        echo "FAIL: namespaceSelector not found in Ingress rule."
        exit 1
    fi
     if [[ "$RAW" != *"frontend"* ]]; then
        echo "FAIL: 'frontend' not found in Ingress rule (did you select the namespace?)."
        exit 1
    fi
fi

# 3. Check Pod Selector (in From)
POD_SEL=$(kubectl get netpol allow-client -n backend -o jsonpath='{.spec.ingress[0].from[1].podSelector.matchLabels.app}')
# Note: indices [0] and [1] depends if they are in same array item or different.
# Proper way: 'from' is a list. elements are OR'd. 
# "From pods with label app=client in frontend namespace" means ONE element in 'from' with BOTH namespaceSelector AND podSelector.

FROM_ITEM=$(kubectl get netpol allow-client -n backend -o jsonpath='{.spec.ingress[0].from[0]}')
if [[ "$FROM_ITEM" != *"namespaceSelector"* || "$FROM_ITEM" != *"podSelector"* ]]; then
     echo "FAIL: Rule must contain BOTH namespaceSelector AND podSelector in the SAME 'from' element (AND logic)."
     echo "Found: $FROM_ITEM"
     exit 1
fi

if [[ "$FROM_ITEM" != *"app"* || "$FROM_ITEM" != *"client"* ]]; then
    echo "FAIL: podSelector does not match app=client."
    exit 1
fi

echo "SUCCESS: NetworkPolicy seems correct (Static check passed)."
