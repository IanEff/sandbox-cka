#!/bin/bash
# workloads/init-container-dependency/setup.sh
kubectl delete pod web-wait 2>/dev/null || true
kubectl delete svc mydb 2>/dev/null || true
