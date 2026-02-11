#!/bin/bash

# Check if deployment is ready
AVAILABLE=$(kubectl get deploy web-frontend -n lifecycle -o jsonpath='{.status.availableReplicas}')
DESIRED=$(kubectl get deploy web-frontend -n lifecycle -o jsonpath='{.spec.replicas}')

if [ "$AVAILABLE" == "$DESIRED" ]; then
    echo "SUCCESS: All replicas are ready and serving traffic."
else
    echo "FAIL: Expected $DESIRED available replicas, found $AVAILABLE."
    exit 1
fi
