#!/bin/bash

# Clean up
kubectl delete pod arthur-dent --force --grace-period=0 2>/dev/null || true

# Create the broken pod
# Pointing to a bogus nameserver
kubectl run arthur-dent \
  --image=busybox:1.28 \
  --restart=Always \
  --overrides='{"spec": {"dnsPolicy": "None", "dnsConfig": {"nameservers": ["1.1.1.1"]}}}' \
  -- sleep 3600

kubectl wait --for=condition=Ready pod/arthur-dent --timeout=60s
