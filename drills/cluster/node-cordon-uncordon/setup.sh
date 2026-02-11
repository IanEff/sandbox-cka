#!/bin/bash
# Setup for node-cordon-uncordon

# Ensure the node is currently schedulable (uncordoned)
kubectl uncordon ubukubu-node-1 || true
