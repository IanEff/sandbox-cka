#!/bin/bash
set -e

# Cleanup
kubectl delete job batch-processor --ignore-not-found
