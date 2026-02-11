#!/bin/bash
# Setup for CSR Drill
set -e

# Cleanup any previous attempt artifacts
rm -f /home/vagrant/jane.key /home/vagrant/jane.csr /home/vagrant/jane.crt

# Cleanup kubeconfig
kubectl config delete-context jane-context >/dev/null 2>&1 || true
kubectl config delete-user jane >/dev/null 2>&1 || true

# Cleanup k8s object
kubectl delete csr jane --ignore-not-found=true

echo "Setup complete. Artifacts cleaned."
