#!/bin/bash
NS="gateway-drill"

# Check Gateway
kubectl get gateway color-gateway -n $NS > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "Gateway 'color-gateway' not found"; exit 1; fi

# Check HTTPRoute
kubectl get httproute color-route -n $NS > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "HTTPRoute 'color-route' not found"; exit 1; fi

# Fast check of YAML for weights
WEIGHT_BLUE=$(kubectl get httproute color-route -n $NS -o jsonpath='{.spec.rules[0].backendRefs[?(@.name=="blue")].weight}')
WEIGHT_GREEN=$(kubectl get httproute color-route -n $NS -o jsonpath='{.spec.rules[0].backendRefs[?(@.name=="green")].weight}')

if [[ "$WEIGHT_BLUE" != "80" ]]; then echo "Blue weight is $WEIGHT_BLUE, expected 80"; exit 1; fi
if [[ "$WEIGHT_GREEN" != "20" ]]; then echo "Green weight is $WEIGHT_GREEN, expected 20"; exit 1; fi

echo "Gateway Traffic Split verified."
exit 0
