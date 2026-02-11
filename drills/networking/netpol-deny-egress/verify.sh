#!/bin/bash
# Verify for netpol-deny-egress

NS="secure-egress"
NP="deny-all-egress"

# 1. Existence
if ! kubectl -n $NS get netpol $NP >/dev/null 2>&1; then
    echo "FAIL: NetworkPolicy not found."
    exit 1
fi

# 2. PolicyTypes (Must contain Egress)
TYPES=$(kubectl -n $NS get netpol $NP -o jsonpath='{.spec.policyTypes}')
if [[ "$TYPES" != *"Egress"* ]]; then
    echo "FAIL: policyTypes must include Egress"
    exit 1
fi

# 3. Egress Rules (Must be empty or non-existent to deny all)
# If 'egress' key exists but list is empty = deny all.
# If 'egress' key is missing with Egress in policyTypes = deny all.
# Caution: If 'egress: [{}]' (empty object in list) = allow all.
EGRESS_RULES=$(kubectl -n $NS get netpol $NP -o jsonpath='{.spec.egress}')

# Check for Allow All case
if [[ "$EGRESS_RULES" == *"{}"* ]]; then
     echo "FAIL: Egress rules appear to allow all (found {})"
     exit 1
fi

echo "SUCCESS: Default deny egress configuration valid."
