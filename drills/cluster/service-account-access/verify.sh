#!/bin/bash
# Verify SA
if ! kubectl get sa deployer -n infra >/dev/null 2>&1; then
    echo "FAIL: ServiceAccount 'deployer' not found in namespace 'infra'"
    exit 1
fi

# Verify Access
if kubectl auth can-i create deployment --as=system:serviceaccount:infra:deployer -A >/dev/null 2>&1; then
    echo "SUCCESS: ServiceAccount has cluster-wide access."
else
    echo "FAIL: ServiceAccount cannot create deployments cluster-wide."
    exit 1
fi
