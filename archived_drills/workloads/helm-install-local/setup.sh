#!/bin/bash
# Setup for helm-install-local drill

# Cleanup
helm uninstall my-jellyfish-release -n jellyfish 2>/dev/null || true
kubectl delete ns jellyfish 2>/dev/null || true
rm -rf /opt/drill-chart

# Create chart
mkdir -p /opt
helm create /opt/drill-chart
