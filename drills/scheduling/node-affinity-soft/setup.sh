#!/bin/bash
set -e

# Cleanup
kubectl delete pod preferred-pod --ignore-not-found

# Ensure no nodes have the label initially (so we can verify soft affinity works even if label missing)
# Or we can add it to one node to see if it moves there.
# For simplicity, we just ensure clean slate.
kubectl label nodes --all disk- --overwrite > /dev/null 2>&1 || true
