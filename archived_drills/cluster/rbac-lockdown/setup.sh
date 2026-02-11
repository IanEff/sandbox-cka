#!/bin/bash
set -e

kubectl create ns rbac-ns --dry-run=client -o yaml | kubectl apply -f -

# Create the service account
kubectl create sa deploy-bot -n rbac-ns --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete. ServiceAccount deploy-bot created but has no permissions."
