#!/bin/bash
# Setup for crd-creation drill

# Ensure clean slate
kubectl delete crd backups.stable.example.com --ignore-not-found
