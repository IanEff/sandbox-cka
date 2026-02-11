#!/bin/bash
# Verify for helm-install-local drill

if helm list -n jellyfish | grep -q "my-jellyfish-release"; then
    echo "Release found."
else
    echo "FAILURE: Release 'my-jellyfish-release' not found in namespace 'jellyfish'."
    exit 1
fi

if kubectl get pods -n jellyfish | grep -q "Running"; then
    echo "SUCCESS: Pods are running."
    exit 0
else
    echo "FAILURE: No running pods found in 'jellyfish' namespace."
    exit 1
fi
