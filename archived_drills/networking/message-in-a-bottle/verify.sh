#!/bin/bash

EPS=$(kubectl get endpoints sos-signal -o jsonpath='{.subsets[*].addresses[*].ip}')

if [ -z "$EPS" ]; then
    echo "FAIL: No endpoints found. The bottle is empty."
    exit 1
else
    echo "SUCCESS: Connection found! Wilson is saved!"
    exit 0
fi
