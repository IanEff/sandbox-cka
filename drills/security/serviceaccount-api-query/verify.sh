#!/bin/bash
# Verify ServiceAccount API Query Drill
set -e

NS="project-api"

# Check Pod exists and uses correct ServiceAccount
if ! kubectl get pod api-query -n $NS >/dev/null 2>&1; then
    echo "FAIL: Pod 'api-query' not found in namespace $NS"
    exit 1
fi

SA=$(kubectl get pod api-query -n $NS -o jsonpath='{.spec.serviceAccountName}')
if [[ "$SA" != "api-explorer" ]]; then
    echo "FAIL: Pod is not using ServiceAccount 'api-explorer' (found: $SA)"
    exit 1
fi
echo "PASS: Pod uses correct ServiceAccount"

# Check result file exists
if [[ ! -f /home/vagrant/api-secrets.json ]]; then
    echo "FAIL: Result file /home/vagrant/api-secrets.json not found"
    exit 1
fi

# Validate it contains secrets data
if ! grep -q '"kind": "SecretList"\|"kind":"SecretList"' /home/vagrant/api-secrets.json 2>/dev/null; then
    # Try items check
    if ! grep -q '"items"' /home/vagrant/api-secrets.json 2>/dev/null; then
        echo "FAIL: Result file does not contain valid Kubernetes API response"
        exit 1
    fi
fi

# Verify our secrets are in the response
if ! grep -q "db-password" /home/vagrant/api-secrets.json; then
    echo "FAIL: Result does not contain 'db-password' secret"
    exit 1
fi

if ! grep -q "api-key" /home/vagrant/api-secrets.json; then
    echo "FAIL: Result does not contain 'api-key' secret"
    exit 1
fi

echo "SUCCESS: ServiceAccount API query completed correctly"
