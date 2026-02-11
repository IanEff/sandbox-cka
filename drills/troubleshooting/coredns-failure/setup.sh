#!/bin/bash
# Setup: Break CoreDNS by scaling it to 0 replicas

# Scale CoreDNS deployment to 0
kubectl scale deployment coredns -n kube-system --replicas=0 &>/dev/null || true

echo "Scaled CoreDNS to 0 replicas, causing DNS resolution failures"
exit 0
