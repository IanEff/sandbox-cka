#!/bin/bash
set -e

echo "Checking RBAC permissions for deploy-bot..."

# Check if deploy-bot can create deployments
CAN_CREATE=$(kubectl auth can-i create deployments --as=system:serviceaccount:rbac-ns:deploy-bot -n rbac-ns 2>/dev/null || echo "no")
CAN_LIST=$(kubectl auth can-i list deployments --as=system:serviceaccount:rbac-ns:deploy-bot -n rbac-ns 2>/dev/null || echo "no")
CAN_DELETE=$(kubectl auth can-i delete deployments --as=system:serviceaccount:rbac-ns:deploy-bot -n rbac-ns 2>/dev/null || echo "no")

# Should NOT have permissions in default namespace
CAN_CREATE_DEFAULT=$(kubectl auth can-i create deployments --as=system:serviceaccount:rbac-ns:deploy-bot -n default 2>/dev/null || echo "no")

echo "Can create deployments in rbac-ns: $CAN_CREATE"
echo "Can list deployments in rbac-ns: $CAN_LIST"
echo "Can delete deployments in rbac-ns: $CAN_DELETE"
echo "Can create deployments in default: $CAN_CREATE_DEFAULT"

if [ "$CAN_CREATE" = "yes" ] && [ "$CAN_LIST" = "yes" ] && [ "$CAN_DELETE" = "yes" ] && [ "$CAN_CREATE_DEFAULT" = "no" ]; then
    echo "SUCCESS: RBAC configured correctly!"
    exit 0
else
    echo "FAIL: RBAC not configured correctly."
    exit 1
fi
