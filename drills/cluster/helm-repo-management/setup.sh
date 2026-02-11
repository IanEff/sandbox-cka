#!/bin/bash
# Setup for helm-repo-management

helm uninstall web-server -n web-ns 2>/dev/null || true
kubectl delete ns web-ns 2>/dev/null || true
helm repo remove bitnami 2>/dev/null || true
