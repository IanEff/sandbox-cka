#!/bin/bash
# Setup for immutable-configmap

kubectl delete ns config-test 2>/dev/null || true
kubectl create ns config-test
