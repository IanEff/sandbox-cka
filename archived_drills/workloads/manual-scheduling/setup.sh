#!/bin/bash
# Clean up potential previous run
kubectl delete pod manual-pod --force --grace-period=0 2>/dev/null || true
echo "Setup complete."
