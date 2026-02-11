#!/bin/bash
NS="security-lockdown"
BACKEND_IP=$(kubectl get pod backend -n $NS -o jsonpath='{.status.podIP}')

# 1. Check Deny All (Rogue should fail)
# timeout is critical for connection refused/timeout tests
timeout 2 kubectl exec -n $NS rogue -- nc -z -v -w 1 $BACKEND_IP 80
if [ $? -eq 0 ]; then
    echo "FAIL: Rogue pod was able to connect (Default Deny missing?)"
    exit 1
fi

# 2. Check Allow (Frontend should succeed)
kubectl exec -n $NS frontend -- nc -z -v -w 1 $BACKEND_IP 80
if [ $? -ne 0 ]; then
    echo "FAIL: Frontend pod unable to connect"
    exit 1
fi

echo "Verification success"
exit 0
