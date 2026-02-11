#!/bin/bash
kubectl delete pod downward-pod --force --grace-period=0 2>/dev/null || true
