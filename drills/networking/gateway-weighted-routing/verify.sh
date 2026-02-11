#!/bin/bash
set -e

# Check HTTPRoute exists
if ! kubectl get httproute weighted-route -n default &>/dev/null; then
    echo "❌ HTTPRoute 'weighted-route' not found in default namespace"
    exit 1
fi

# Check parent reference to gateway
gateway_ref=$(kubectl get httproute weighted-route -n default -o jsonpath='{.spec.parentRefs[0].name}')
if [ "$gateway_ref" != "main-gateway" ]; then
    echo "❌ HTTPRoute does not reference 'main-gateway' (found: '$gateway_ref')"
    exit 1
fi

# Check path match
path_match=$(kubectl get httproute weighted-route -n default -o jsonpath='{.spec.rules[0].matches[0].path.value}')
if [ "$path_match" != "/app" ]; then
    echo "❌ HTTPRoute path match is '$path_match', expected '/app'"
    exit 1
fi

# Check backend refs and weights
backend_refs=$(kubectl get httproute weighted-route -n default -o jsonpath='{.spec.rules[0].backendRefs}')

# Check app-v1 weight (80)
v1_weight=$(kubectl get httproute weighted-route -n default -o jsonpath='{.spec.rules[0].backendRefs[?(@.name=="app-v1")].weight}')
if [ "$v1_weight" != "80" ]; then
    echo "❌ app-v1 weight is '$v1_weight', expected '80'"
    exit 1
fi

# Check app-v2 weight (20)
v2_weight=$(kubectl get httproute weighted-route -n default -o jsonpath='{.spec.rules[0].backendRefs[?(@.name=="app-v2")].weight}')
if [ "$v2_weight" != "20" ]; then
    echo "❌ app-v2 weight is '$v2_weight', expected '20'"
    exit 1
fi

# Check ports
v1_port=$(kubectl get httproute weighted-route -n default -o jsonpath='{.spec.rules[0].backendRefs[?(@.name=="app-v1")].port}')
v2_port=$(kubectl get httproute weighted-route -n default -o jsonpath='{.spec.rules[0].backendRefs[?(@.name=="app-v2")].port}')

if [ "$v1_port" != "8080" ] || [ "$v2_port" != "8080" ]; then
    echo "❌ Backend ports not set to 8080"
    exit 1
fi

echo "✅ HTTPRoute configured correctly with 80/20 traffic split"
exit 0
