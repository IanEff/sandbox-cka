#!/bin/bash
# Verify Egress NetworkPolicy Drill
set -e

NS="secure-app"

# Check NetworkPolicy exists
if ! kubectl get networkpolicy restricted-egress -n $NS >/dev/null 2>&1; then
    echo "FAIL: NetworkPolicy 'restricted-egress' not found in namespace $NS"
    exit 1
fi

echo "Testing DNS resolution from api pod (should SUCCEED)..."
if ! timeout 10 kubectl exec -n $NS api-server -- nslookup kubernetes.default.svc.cluster.local >/dev/null 2>&1; then
    echo "FAIL: DNS resolution blocked. API pods cannot resolve DNS."
    exit 1
fi
echo "PASS: DNS resolution works"

echo "Testing connection to database:5432 (should SUCCEED)..."
DB_IP=$(kubectl get pod database -n $NS -o jsonpath='{.status.podIP}')
if ! timeout 5 kubectl exec -n $NS api-server -- nc -zv $DB_IP 5432 2>&1 | grep -q "open\|succeeded"; then
    # Try wget as fallback (nginx is on port 80 but exposed as 5432->80)
    if ! timeout 5 kubectl exec -n $NS api-server -- wget -q -O /dev/null --timeout=3 http://$DB_IP:80 2>/dev/null; then
        echo "FAIL: Cannot connect to database pod"
        exit 1
    fi
fi
echo "PASS: Connection to database allowed"

echo "Testing connection to forbidden service (should FAIL)..."
FORBIDDEN_IP=$(kubectl get pod forbidden-svc -n $NS -o jsonpath='{.status.podIP}')
if timeout 3 kubectl exec -n $NS api-server -- wget -q -O /dev/null --timeout=2 http://$FORBIDDEN_IP:80 2>/dev/null; then
    echo "FAIL: Connection to forbidden service was allowed (should be blocked)"
    exit 1
fi
echo "PASS: Connection to forbidden service blocked"

echo "SUCCESS: Egress NetworkPolicy correctly configured"
