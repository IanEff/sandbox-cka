#!/bin/bash
set -e

# Check if Bound
kubectl get pvc manual-pvc -o jsonpath='{.status.phase}' | grep Bound
