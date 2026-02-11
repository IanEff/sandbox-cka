#!/bin/bash

# Find Gateway IP
GW_IP=$(kubectl get gateway drill-gateway -n drill-gateway -o jsonpath='{.status.addresses[0].value}')

if [ -z "$GW_IP" ]; then
    echo "Gateway IP not found. Ensure Gateway is named 'drill-gateway' in namespace 'drill-gateway'."
    exit 1
fi

echo "Gateway IP: $GW_IP"

# Check Default Route (Should be nginx / v1)
echo "Checking default route..."
DEFAULT_RESP=$(timeout 2 curl -s http://$GW_IP)
if echo "$DEFAULT_RESP" | grep -q "nginx"; then
    echo "Default route -> v1 (nginx) OK"
else
    echo "Default route failed. Expected nginx, got: ${DEFAULT_RESP:0:50}..."
    exit 1
fi

# Check v2 Route (Should be httpd / v2)
echo "Checking v2 route..."
V2_RESP=$(timeout 2 curl -s -H "Version: v2" http://$GW_IP)
if echo "$V2_RESP" | grep -q "It works"; then
    echo "Header route -> v2 (httpd) OK"
else
    echo "v2 route failed. Expected 'It works', got: ${V2_RESP:0:50}..."
    exit 1
fi

echo "Drill passed!"
exit 0
