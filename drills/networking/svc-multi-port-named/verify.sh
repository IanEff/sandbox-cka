#!/bin/bash
set -e

# Verification Script

# 1. Check Service Port 80
PORT_80_TARGET=$(kubectl get svc web-service -n multi-port -o jsonpath='{.spec.ports[?(@.port==80)].targetPort}')
if [ "$PORT_80_TARGET" != "http-backend" ]; then
    echo "FAIL: Service port 80 targets '$PORT_80_TARGET', expected 'http-backend'"
    exit 1
fi

# 2. Check Service Port 443
PORT_443_TARGET=$(kubectl get svc web-service -n multi-port -o jsonpath='{.spec.ports[?(@.port==443)].targetPort}')
if [ "$PORT_443_TARGET" != "https-backend" ]; then
    echo "FAIL: Service port 443 targets '$PORT_443_TARGET', expected 'https-backend'"
    exit 1
fi

# 3. Connectivity Check
# Use a temp pod to curl the service
kubectl delete pod curl-test -n multi-port --ignore-not-found=true --force --grace-period=0
kubectl run curl-test --image=curlimages/curl --restart=Never -n multi-port -- curl -s -m 2 http://web-service:80 > /dev/null

echo "SUCCESS: Multi-port named drill passed."
