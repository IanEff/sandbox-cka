#!/bin/bash
# Setup for helm-install-chart
# Ensure clean state

helm uninstall neon-gateway -n neon-city 2>/dev/null || true
kubectl delete ns neon-city 2>/dev/null || true
