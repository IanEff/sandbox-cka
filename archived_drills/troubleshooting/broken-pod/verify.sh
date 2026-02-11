#!/bin/bash
STATUS=$(kubectl get pod web-frontend -n dev -o jsonpath='{.status.phase}')
if [ "$STATUS" == "Running" ]; then
    echo "Pod is Running!"
    exit 0
else
    echo "Pod is in state: $STATUS"
    exit 1
fi
