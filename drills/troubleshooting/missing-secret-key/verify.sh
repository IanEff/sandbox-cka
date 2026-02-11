#!/bin/bash
if kubectl wait --for=condition=ready pod -l app=viewer -n debug-me --timeout=10s; then
    echo "SUCCESS: Pod is ready."
    exit 0
else
    echo "FAIL: Pod is not ready."
    exit 1
fi
