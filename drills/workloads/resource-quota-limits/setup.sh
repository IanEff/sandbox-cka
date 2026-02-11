#!/bin/bash
# Setup: Create namespace

kubectl create namespace team-blue --dry-run=client -o yaml | kubectl apply -f - &>/dev/null

echo "Created namespace team-blue"
exit 0
