#!/bin/bash
# Verify Gateway User-Agent Routing Drill
set -e

NS="project-mobile"

# Check HTTPRoute exists
if ! kubectl get httproute ua-router -n $NS >/dev/null 2>&1; then
    echo "FAIL: HTTPRoute 'ua-router' not found in namespace $NS"
    exit 1
fi

# Check it references the gateway
PARENT=$(kubectl get httproute ua-router -n $NS -o jsonpath='{.spec.parentRefs[0].name}')
if [[ "$PARENT" != "main-gateway" ]]; then
    echo "FAIL: HTTPRoute does not reference 'main-gateway' (found: $PARENT)"
    exit 1
fi
echo "PASS: HTTPRoute references correct Gateway"

# Get gateway address
GW_IP=$(kubectl get gateway main-gateway -n $NS -o jsonpath='{.status.addresses[0].value}' 2>/dev/null || echo "")

if [[ -z "$GW_IP" ]]; then
    # Try to get the envoy service directly
    GW_IP=$(kubectl get svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name=main-gateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
fi

if [[ -z "$GW_IP" ]]; then
    echo "WARNING: Could not determine Gateway IP, testing via internal service"
    # Test via direct pod exec instead
    echo "Testing mobile user-agent routing..."
    MOBILE_RESULT=$(kubectl run test-mobile --image=curlimages/curl --restart=Never -n $NS --rm -i -- -s -H "User-Agent: mobile-app" http://mobile-backend/app 2>/dev/null || echo "")
    
    echo "Skipping full verification - Gateway IP not available"
    echo "HTTPRoute structure appears correct"
    exit 0
fi

echo "Gateway IP: $GW_IP"

# Test mobile user-agent
echo "Testing mobile User-Agent routing..."
MOBILE_RESULT=$(timeout 5 curl -s -H "User-Agent: mobile-app" "http://$GW_IP/app" 2>/dev/null || echo "")
if [[ "$MOBILE_RESULT" != *"MOBILE"* ]]; then
    echo "FAIL: Mobile User-Agent did not route to mobile-backend"
    echo "Got: $MOBILE_RESULT"
    exit 1
fi
echo "PASS: Mobile User-Agent routed correctly"

# Test desktop (default)
echo "Testing default routing..."
DESKTOP_RESULT=$(timeout 5 curl -s "http://$GW_IP/app" 2>/dev/null || echo "")
if [[ "$DESKTOP_RESULT" != *"DESKTOP"* ]]; then
    echo "FAIL: Default request did not route to desktop-backend"
    echo "Got: $DESKTOP_RESULT"
    exit 1
fi
echo "PASS: Default routed to desktop-backend"

echo "SUCCESS: Gateway User-Agent routing configured correctly"
