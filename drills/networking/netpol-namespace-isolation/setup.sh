#!/bin/bash
# Idempotent setup for Namespace Isolation Drill

# 1. Create Namespace
kubectl create ns restricted-2 --dry-run=client -o yaml | kubectl apply -f -


# 2. Sensitive DB (Redis) - Pod and Service
kubectl delete pod sensitive-db -n restricted-2 --ignore-not-found
kubectl run sensitive-db --image=redis --labels="app=db" -n restricted-2 --dry-run=client -o yaml | kubectl apply -f -
kubectl create service clusterip sensitive-db --tcp=6379:6379 -n restricted-2 --dry-run=client -o yaml | kubectl apply -f -

# 3. Public Web (Nginx) - Pod and Service
kubectl delete pod public-web -n restricted-2 --ignore-not-found
kubectl run public-web --image=nginx --labels="app=web" -n restricted-2 --dry-run=client -o yaml | kubectl apply -f -
kubectl create service clusterip public-web --tcp=80:80 -n restricted-2 --dry-run=client -o yaml | kubectl apply -f -

# 4. Trusted client in default
kubectl delete pod trusted-client -n default --ignore-not-found
kubectl run trusted-client --image=busybox --labels="role=trusted" -n default --dry-run=client -o yaml -- sleep 3600 | kubectl apply -f -

# 5. Untrusted client in default
kubectl delete pod untrusted-client -n default --ignore-not-found
kubectl run untrusted-client --image=busybox --labels="role=unknown" -n default --dry-run=client -o yaml -- sleep 3600 | kubectl apply -f -

# Wait for pods to be running so the user can immediately start testing/verifying?
# drills/ instructions don't explicitly require setup to wait, but it helps stability.
# However, adding waits might make setup slow. We will skip explicit waits to keep it snappy unless user complains.
# The error reported was "invalid object", which was caused by the flag ordering.
