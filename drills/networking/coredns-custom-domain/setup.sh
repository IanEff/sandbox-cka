#!/bin/bash
# Setup for CoreDNS Custom Domain Drill
set -e

# Remove any previous backup
rm -f /home/vagrant/coredns-backup.yaml

# Restore CoreDNS to default state if modified
# This is a safety measure - we'll just note the current state
kubectl get configmap coredns -n kube-system -o yaml > /tmp/coredns-current.yaml

echo "Setup complete."
echo "1. Backup CoreDNS ConfigMap to /home/vagrant/coredns-backup.yaml"
echo "2. Add custom domain 'internal.company' alongside 'cluster.local'"
echo "3. Both domains should resolve Kubernetes services"
