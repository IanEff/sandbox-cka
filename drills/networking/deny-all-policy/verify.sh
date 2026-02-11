#!/bin/bash

API_IP=$(kubectl get pod api -n secure-drill -o jsonpath='{.status.podIP}')
if [ -z "$API_IP" ]; then echo "API Pod IP not found"; exit 1; fi

echo "Testing Intruder (Should Fail)..."
if kubectl exec -n secure-drill intruder -- timeout 2 wget -qO- $API_IP; then
    echo "Fail: Intruder could connect!"
    exit 1
else
    echo "Intruder blocked. Good."
fi

echo "Testing Frontend (Should Pass)..."
if kubectl exec -n secure-drill frontend -- timeout 2 wget -qO- $API_IP; then
     echo "Frontend connected. Success."
     exit 0
else
     echo "Fail: Frontend blocked!"
     exit 1
fi
