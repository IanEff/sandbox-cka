#!/bin/bash
DIR="/opt/course/overlay8"
NS="broken-app"

# Check if endpoints exist (Success condition)
EP_COUNT=$(kubectl get endpoints backend-svc -n $NS -o jsonpath='{.subsets[*].addresses[*].ip}' | wc -w)
if [ "$EP_COUNT" -eq 0 ]; then
    echo "Service has no endpoints. Fix not applied."
    exit 1
fi

if [ ! -f "$DIR/success.txt" ]; then echo "Missing success.txt"; exit 1; fi
if [ ! -f "$DIR/postmortem.txt" ]; then echo "Missing postmortem.txt"; exit 1; fi

exit 0
