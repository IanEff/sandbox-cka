#!/bin/bash
# Verify NetPol existence
NETPOL=$(kubectl get netpol -n restricted -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$NETPOL" ]; then
    echo "FAIL: No NetworkPolicy found in namespace 'restricted'"
    exit 1
fi

# We can check specific rules via jsonpath, but that's fragile to ordering.
# Instead, let's verify logic by inspecting the json output for key elements.
JSON=$(kubectl get netpol $NETPOL -n restricted -o json)

# Check PolicyTypes includes Egress
if ! echo "$JSON" | grep -q '"Egress"'; then
    echo "FAIL: PolicyTypes does not include Egress"
    exit 1
fi

# Check for IPBlock 1.1.1.1
if ! echo "$JSON" | grep -q '1.1.1.1'; then
     echo "FAIL: 1.1.1.1 not found in policy"
     exit 1
fi

# Check for Port 53
if ! echo "$JSON" | grep -q '53'; then
    echo "FAIL: Port 53 not found"
    exit 1
fi

echo "SUCCESS: NetworkPolicy present with required elements."
