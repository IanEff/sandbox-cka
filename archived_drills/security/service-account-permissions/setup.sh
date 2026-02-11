#!/bin/bash
# Setup for service-account-permissions drill

# Cleanup
kubectl delete pod monitor-pod --force --grace-period=0 2>/dev/null || true
kubectl delete role monitor-role 2>/dev/null || true
kubectl delete rolebinding monitor-binding 2>/dev/null || true
kubectl delete sa monitor 2>/dev/null || true
