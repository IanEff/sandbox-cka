#!/bin/bash
# Setup for job-completion-handling

# Ensure namespace exists
kubectl create namespace job-specialist --dry-run=client -o yaml | kubectl apply -f -

# Clean up any existing job if present (idempotency)
kubectl -n job-specialist delete job batch-processor --ignore-not-found
