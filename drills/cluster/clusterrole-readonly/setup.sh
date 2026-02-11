#!/bin/bash
# Setup: Create monitoring namespace

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f - &>/dev/null

echo "Created monitoring namespace"
exit 0
