#!/bin/bash
set -e

NS="project-snake"
BACKEND_POD=$(kubectl get pod -n $NS -l app=backend -o jsonpath='{.items[0].metadata.name}')
DB1_IP=$(kubectl get pod -n $NS -l app=db1 -o jsonpath='{.items[0].status.podIP}')
DB2_IP=$(kubectl get pod -n $NS -l app=db2 -o jsonpath='{.items[0].status.podIP}')
VAULT_IP=$(kubectl get pod -n $NS -l app=vault -o jsonpath='{.items[0].status.podIP}')

# Check 1: Allowed DB1 port 1111
if ! kubectl exec -n $NS $BACKEND_POD -- nc -z -v -w 2 $DB1_IP 1111; then
    echo "FAIL: Cannot connect to DB1:1111"
    exit 1
fi

# Check 2: Allowed DB2 port 2222
if ! kubectl exec -n $NS $BACKEND_POD -- nc -z -v -w 2 $DB2_IP 2222; then
    echo "FAIL: Cannot connect to DB2:2222"
    exit 1
fi

# Check 3: Blocked Vault port 3333
echo "Verifying Blocked Traffic (should fail)..."
if kubectl exec -n $NS $BACKEND_POD -- nc -z -v -w 2 $VAULT_IP 3333; then
    echo "FAIL: Connected to Vault:3333 (Should be blocked)"
    exit 1
else
    echo "Success: Blocked Vault:3333"
fi

# Check 4: Blocked DB1 port 1112 (wrong port check)
if kubectl exec -n $NS $BACKEND_POD -- nc -z -v -w 2 $DB1_IP 1112; then
  echo "FAIL: Connected to DB1 wrong port (Should be blocked)"
  exit 1
fi

echo "All Checks Passed"
exit 0
