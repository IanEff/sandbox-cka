#!/bin/bash
NS="rbac-drill"
SA="system:serviceaccount:$NS:limited-user"

# Check Deployment create (Allowed)
kubectl auth can-i create deployment --as=$SA -n $NS | grep -q "yes"
if [ $? -ne 0 ]; then echo "Should be able to create deployments"; exit 1; fi

# Check Deployment delete (Allowed)
kubectl auth can-i delete deployment --as=$SA -n $NS | grep -q "yes"
if [ $? -ne 0 ]; then echo "Should be able to delete deployments"; exit 1; fi

# Check Pod list (Allowed)
kubectl auth can-i list pods --as=$SA -n $NS | grep -q "yes"
if [ $? -ne 0 ]; then echo "Should be able to list pods"; exit 1; fi

# Check Pod delete (Denied)
kubectl auth can-i delete pods --as=$SA -n $NS | grep -q "no"
if [ $? -ne 0 ]; then echo "Should NOT be able to delete pods"; exit 1; fi

echo "RBAC permissions verified."
exit 0
