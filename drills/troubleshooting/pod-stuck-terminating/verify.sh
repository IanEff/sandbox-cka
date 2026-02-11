#!/bin/bash
if kubectl get pod cant-stop 2>/dev/null; then
    echo "Pod cant-stop still exists"
    exit 1
else
    echo "Pod cant-stop is gone"
fi
