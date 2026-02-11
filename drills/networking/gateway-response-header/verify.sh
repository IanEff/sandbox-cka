#!/bin/bash
GW_IP=$(kubectl get gateway my-gateway -n gateway-test -o jsonpath='{.status.addresses[0].value}')

if [ -z "$GW_IP" ]; then
    echo "Gateway IP not assigned."
    exit 1
fi

# Curl and check headers.
# Using 'grep' to check X-Verified: true
EXIT_CODE=0
curl -s -I "http://$GW_IP" | grep -i "X-Verified: true" || EXIT_CODE=1

if [ $EXIT_CODE -eq 0 ]; then
    exit 0
else
    echo "Header X-Verified: true not found."
    exit 1
fi
