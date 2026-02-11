#!/bin/bash
kubectl delete ns infra 2>/dev/null || true
kubectl delete clusterrolebinding deployer-binding 2>/dev/null || true
