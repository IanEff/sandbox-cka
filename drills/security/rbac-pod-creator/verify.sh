#!/bin/bash
NS="dev-team"
SA="system:serviceaccount:$NS:developer"

# Check Create
if ! kubectl auth can-i create pods --as $SA -n $NS | grep -q "yes"; then
  echo "FAIL: SA cannot create pods"
  exit 1
fi

# Check List
if ! kubectl auth can-i list pods --as $SA -n $NS | grep -q "yes"; then
  echo "FAIL: SA cannot list pods"
  exit 1
fi

# Check Delete (Must be no)
if kubectl auth can-i delete pods --as $SA -n $NS | grep -q "yes"; then
  echo "FAIL: SA CAN delete pods (should not be allowed)"
  exit 1
fi

echo "SUCCESS: RBAC configured correctly"
exit 0
