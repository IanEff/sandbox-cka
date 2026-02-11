#!/bin/bash
# Setup for env-from-aggregation

kubectl delete ns env-mix 2>/dev/null || true
kubectl create ns env-mix
