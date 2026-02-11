#!/bin/bash
# Verify CSR Drill
set -e

echo "Checking CSR object..."
CSR_STATUS=$(kubectl get csr jane -o jsonpath='{.status.conditions[0].type}')
if [ "$CSR_STATUS" != "Approved" ]; then
    echo "FAIL: CSR 'jane' is not approved or does not exist."
    exit 1
fi

echo "Checking Kubeconfig Context..."
if ! kubectl config get-contexts jane-context >/dev/null 2>&1; then
    echo "FAIL: Context 'jane-context' not found."
    exit 1
fi

echo "Checking Authentication..."
# We expect 'Forbidden' (403) not 'Unauthorized' (401)
# 403 means identity key/cert is valid, but RBAC denied access (we didn't ask to set up RBAC).
# 401 means invalid credentials.
OUTPUT=$(kubectl --context=jane-context get pods 2>&1 || true)

if echo "$OUTPUT" | grep -q "Forbidden"; then
    echo "SUCCESS: Authentication successful (Access Forbidden as expected)."
    exit 0
elif echo "$OUTPUT" | grep -q "No resources found"; then
    # In case default permissions allow it
    echo "SUCCESS: Authentication successful."
    exit 0
else
    echo "FAIL: Connection test failed. Output: $OUTPUT"
    exit 1
fi
