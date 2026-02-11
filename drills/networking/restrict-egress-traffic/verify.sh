#!/bin/bash

# Check pod
if ! kubectl get pod restricted-pod -n secure-net &>/dev/null; then
  echo "ERROR: Pod restricted-pod not found"
  exit 1
fi

kubectl wait --for=condition=ready pod/restricted-pod -n secure-net --timeout=30s &>/dev/null

# Check NetPol
if ! kubectl get netpol deny-external-egress -n secure-net &>/dev/null; then
  echo "ERROR: NetworkPolicy deny-external-egress not found"
  exit 1
fi

# Verify Policy Structure (Basic check)
EGRESS_RULES=$(kubectl get netpol deny-external-egress -n secure-net -o jsonpath='{.spec.egress}')
if [[ -z "$EGRESS_RULES" ]]; then
  echo "ERROR: NetworkPolicy has no egress rules"
  exit 1
fi

# Functional Verification
# 1. DNS should work
echo "Testing DNS..."
if ! kubectl exec restricted-pod -n secure-net -- nslookup kubernetes.default &>/dev/null; then
  echo "ERROR: DNS lookup failed. Egress to port 53 might be blocked."
  exit 1
fi

# 2. External IP should fail (timeout)
echo "Testing External Ping (should fail)..."
# We use timeout because if it works it will hang or succeed fast. If it's blocked (drop), it might hang.
if kubectl exec restricted-pod -n secure-net -- timeout 3 ping -c 1 8.8.8.8 &>/dev/null; then
  echo "ERROR: Ping to 8.8.8.8 SUCCEEDED. Egress is not restricted properly."
  exit 1
fi

echo "SUCCESS: Egress restricted properly (DNS allowed, External blocked)"
exit 0
