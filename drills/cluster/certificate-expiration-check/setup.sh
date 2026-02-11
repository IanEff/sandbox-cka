#!/bin/bash
set -e

# This drill doesn't need to create broken state - it's an inspection exercise
# The cluster certificates already exist from the kubeadm installation

echo "Setup complete. Use kubeadm to check certificate expiration status."
echo "Run the check on the control plane node and save output to /tmp/cert-status.txt"
