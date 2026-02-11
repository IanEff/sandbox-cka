#!/bin/bash
# workloads/security-context-capabilities/setup.sh
kubectl delete pod secure-cap --force --grace-period=0 2>/dev/null || true
