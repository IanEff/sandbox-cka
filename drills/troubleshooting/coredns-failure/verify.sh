#!/bin/bash
set -e

# Check CoreDNS deployment has at least 1 ready replica
ready_replicas=$(kubectl get deployment coredns -n kube-system -o jsonpath='{.status.readyReplicas}')

if [ -z "$ready_replicas" ] || [ "$ready_replicas" -lt 1 ]; then
    echo "❌ CoreDNS has no ready replicas (found: ${ready_replicas:-0})"
    exit 1
fi

# Wait for CoreDNS to be ready
if ! kubectl wait --for=condition=available --timeout=30s deployment/coredns -n kube-system &>/dev/null; then
    echo "❌ CoreDNS deployment is not available"
    exit 1
fi

# Test DNS resolution with a temporary pod
timeout 10 kubectl run dns-verify --image=busybox:1.36 --rm -i --restart=Never --command -- nslookup kubernetes.default.svc.cluster.local &>/dev/null
dns_test=$?

if [ $dns_test -ne 0 ]; then
    echo "❌ DNS resolution test failed"
    kubectl delete pod dns-verify --ignore-not-found=true &>/dev/null
    exit 1
fi

echo "✅ CoreDNS is functioning and DNS resolution works"
exit 0
