#!/bin/bash
NS="debug-svc"

# Check if Service has endpoints
EPS=$(kubectl get endpoints frontend-svc -n $NS -o jsonpath='{.subsets[*].addresses[*].ip}' | wc -w)

if [ "$EPS" -eq 0 ]; then
    echo "FAIL: No endpoints found for Service 'frontend-svc'. Selector likely still broken."
    exit 1
fi

# Functional test (within cluster)
# Start a temp pod to curl
kubectl run tester --image=curlimages/curl --rm -it --restart=Never -n $NS -- curl -s --connect-timeout 2 frontend-svc
if [ $? -ne 0 ]; then
    echo "FAIL: Curl to service failed"
    exit 1
fi

echo "Verification success"
exit 0
