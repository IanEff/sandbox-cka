#!/bin/bash
# security/service-account-token-mount/setup.sh
kubectl delete pod no-token 2>/dev/null || true
