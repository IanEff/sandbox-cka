#!/bin/bash
# Verify for readiness-probe-exec

POD="ready-checker"

# 1. Existence
if ! kubectl get pod $POD >/dev/null 2>&1; then
    echo "FAIL: Pod not found."
    exit 1
fi

# 2. Check Probe Config
CMD=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].readinessProbe.exec.command}')
PERIOD=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].readinessProbe.periodSeconds}')

if [[ "$CMD" != *"cat"* ]] || [[ "$CMD" != *"/tmp/health"* ]]; then
    echo "FAIL: Probe command does not look right. Got: $CMD"
    exit 1
fi

if [[ "$PERIOD" != "5" ]]; then
    echo "FAIL: Probe period is $PERIOD, expected 5."
    exit 1
fi

echo "SUCCESS: Readiness probe configured."
