#!/bin/bash
# Setup: Ensure namespace exists (idempotent)
kubectl create namespace default --dry-run=client -o yaml | kubectl apply -f - &>/dev/null

# No pre-existing broken state - user creates from scratch
exit 0
