#!/bin/bash
set -e

# Setup just the namespace and maybe the pod, but let user do the work mainly
kubectl create namespace secure-net --dry-run=client -o yaml | kubectl apply -f -

# Clean existing
kubectl delete pod restricted-pod -n secure-net --ignore-not-found
kubectl delete netpol deny-external-egress -n secure-net --ignore-not-found

# We'll let the user create the pod themselves as part of the drill requirements
# to ensure they label it correctly for the netpol to matches.

echo "Setup complete. Namespace 'secure-net' created."
