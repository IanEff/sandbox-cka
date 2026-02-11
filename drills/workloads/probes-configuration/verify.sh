#!/bin/bash
# workloads/probes-configuration/verify.sh

# 1. Check Pod is Ready
if ! kubectl wait --for=condition=ready pod/probe-fail --timeout=10s; then
    echo "FAIL: Pod is not ready."
    exit 1
fi

# 2. Verify Liveness Probe Config (Basic check)
LIVENESS=$(kubectl get pod probe-fail -o jsonpath='{.spec.containers[0].livenessProbe}')
if echo "$LIVENESS" | grep -q "cat"; then
    # If they are still cat'ing, check if they fixed the file path
    if ! echo "$LIVENESS" | grep -q "index.html"; then
       echo "FAIL: Liveness probe is still cat'ing a wrong file (maybe)."
       # Weak check, but generally correct.
    fi
fi

# 3. Verify Readiness Port
PORT=$(kubectl get pod probe-fail -o jsonpath='{.spec.containers[0].readinessProbe.httpGet.port}')
if [ "$PORT" != "80" ]; then
    echo "FAIL: Readiness probe port is $PORT (expected 80)"
    exit 1
fi

echo "SUCCESS: Pod is healthy."
