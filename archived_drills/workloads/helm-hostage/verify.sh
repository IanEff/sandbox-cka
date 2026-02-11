#!/bin/bash
set -e

# Check if release exists and is deployed
helm status broken-app > /dev/null

# Check if pod is running
# Label selector for default helm create chart is app.kubernetes.io/instance=broken-app
kubectl get pods -l app.kubernetes.io/instance=broken-app | grep Running
