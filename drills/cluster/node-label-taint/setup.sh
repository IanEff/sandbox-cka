#!/bin/bash
# Setup for node-label-taint

# Remove label if exists
kubectl label node ubukubu-node-1 hardware- --overwrite >/dev/null 2>&1 || true
# Remove taint if exists
kubectl taint node ubukubu-node-1 dedicated- >/dev/null 2>&1 || true
