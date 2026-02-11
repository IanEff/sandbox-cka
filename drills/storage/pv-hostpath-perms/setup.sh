#!/bin/bash
# Setup for pv-hostpath-perms

# Clean up
kubectl delete pod writer --ignore-not-found
kubectl delete pvc local-claim --ignore-not-found
kubectl delete pv local-store --ignore-not-found
