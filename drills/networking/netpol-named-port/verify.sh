#!/bin/bash
set -e

# Ensure backend acts as server
kubectl wait --for=condition=ready pod/backend -n netpol-demo --timeout=60s > /dev/null

# Verify NetworkPolicy exists
if ! kubectl get netpol allow-metrics-only -n netpol-demo > /dev/null 2>&1; then
    echo "FAIL: NetworkPolicy 'allow-metrics-only' does not exist."
    exit 1
fi

# Check if it uses named port
PORT_NAME=$(kubectl get netpol allow-metrics-only -n netpol-demo -o jsonpath='{.spec.ingress[0].ports[0].port}')
if [ "$PORT_NAME" != "http-metrics" ]; then
    echo "FAIL: NetworkPolicy does not target the named port 'http-metrics'. Found: $PORT_NAME"
    exit 1
fi

# Launch a consumer pod to test connectivity
kubectl run consumer --image=busybox --restart=Never -n netpol-demo -- rm -f /tmp/nc-outputs > /dev/null 2>&1 || true
kubectl wait --for=condition=ready pod/consumer -n netpol-demo --timeout=60s > /dev/null

# Test connectivity (should succeed)
if kubectl exec consumer -n netpol-demo -- nc -z -v -w 2 backend 80; then
    echo "SUCCESS: Traffic allowed on port 80 (http-metrics)."
else
    echo "FAIL: Trafffic blocked on port 80 (http-metrics)."
    exit 1
fi

# Clean up consumer
kubectl delete pod consumer -n netpol-demo --force --grace-period=0 > /dev/null 2>&1

echo "SUCCESS: NetworkPolicy configured correctly."
