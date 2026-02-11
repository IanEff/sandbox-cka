#!/bin/bash
set -e

# Check existence
kubectl get widget spinner

# Check value
SPEED=$(kubectl get widget spinner -o jsonpath='{.spec.speed}')
if [ "$SPEED" != "100" ]; then
    echo "Speed is $SPEED, expected 100"
    exit 1
fi
