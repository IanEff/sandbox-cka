#!/bin/bash
set -e

# Check if pod is running
kubectl get pods -l app=precious | grep Running
