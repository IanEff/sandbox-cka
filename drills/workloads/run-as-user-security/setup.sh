#!/bin/bash
kubectl delete pod secure-pod --force --grace-period=0 2>/dev/null || true
