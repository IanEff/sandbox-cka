#!/bin/bash
# Verify for service-loadbalancer-metallb

SVC="lb-service"

# 1. Type Check
TYPE=$(kubectl get svc $SVC -o jsonpath='{.spec.type}')
if [ "$TYPE" != "LoadBalancer" ]; then
    echo "FAIL: Service type is $TYPE, expected LoadBalancer"
    exit 1
fi

# 2. IP Check
IP=$(kubectl get svc $SVC -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -z "$IP" ]; then
    echo "FAIL: No External IP assigned yet."
    exit 1
fi

echo "SUCCESS: Service has LoadBalancer IP: $IP"
