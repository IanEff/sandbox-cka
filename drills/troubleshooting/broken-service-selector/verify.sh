#!/bin/bash
# Check if endpoints exist
EP=$(kubectl get endpoints broken-svc -o jsonpath='{.subsets[0].addresses[0].ip}')
if [[ -n "$EP" ]]; then
    exit 0
else
    echo "No endpoints found for broken-svc"
    exit 1
fi
