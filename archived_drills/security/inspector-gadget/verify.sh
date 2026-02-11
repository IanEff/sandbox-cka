#!/bin/bash

# Use kubectl auth can-i to verify permissions directly
# This avoids issues with kubectl exec if the cluster networking is flaky.
# We check if the ServiceAccount 'gadget-sa' in 'go-go' can list secrets in 'go-go'.

RESULT=$(kubectl auth can-i list secrets --as=system:serviceaccount:go-go:gadget-sa -n go-go)

if [ "$RESULT" == "yes" ]; then
    echo "SUCCESS: Gadget can list secrets!"
else
    echo "FAIL: Gadget cannot list secrets (auth check returned '$RESULT')."
    exit 1
fi
