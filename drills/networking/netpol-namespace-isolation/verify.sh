#!/bin/bash

# Ensure pods are ready before testing connectivity
kubectl wait --for=condition=ready pod -l role=trusted -n default --timeout=60s > /dev/null 2>&1
kubectl wait --for=condition=ready pod -l role=unknown -n default --timeout=60s > /dev/null 2>&1
kubectl wait --for=condition=ready pod -l app=db -n restricted-2 --timeout=60s > /dev/null 2>&1
kubectl wait --for=condition=ready pod -l app=web -n restricted-2 --timeout=60s > /dev/null 2>&1

# 1. Trusted client -> Sensitivity DB (Should Pass)
kubectl exec -n default trusted-client -- timeout 2 nc -zv sensitive-db.restricted-2.svc.cluster.local 6379
if [ $? -ne 0 ]; then echo "FAIL: Trusted client blocked from DB"; exit 1; fi

# 2. Untrusted client -> Sensitive DB (Should Fail)
kubectl exec -n default untrusted-client -- timeout 2 nc -zv sensitive-db.restricted-2.svc.cluster.local 6379
if [ $? -eq 0 ]; then echo "FAIL: Untrusted client allowed to DB"; exit 1; fi

# 3. Untrusted client -> Public Web (Should Pass - verifying no accidental block)
kubectl exec -n default untrusted-client -- timeout 2 nc -zv public-web.restricted-2.svc.cluster.local 80
if [ $? -ne 0 ]; then echo "FAIL: Public web blocked"; exit 1; fi

echo "SUCCESS: Network Policies configured correctly."
exit 0
