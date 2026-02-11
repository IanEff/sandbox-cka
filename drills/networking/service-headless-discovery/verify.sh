#!/bin/bash
# Verify for service-headless-discovery

SVC="db-headless"

# 1. Check ClusterIP
IP=$(kubectl get svc $SVC -o jsonpath='{.spec.clusterIP}')
if [ "$IP" != "None" ]; then
    echo "FAIL: ClusterIP is '$IP', expected 'None'"
    exit 1
fi

echo "SUCCESS: Headless Service configured."
