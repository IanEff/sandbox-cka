#!/bin/bash
set -e

echo "Checking HPA configuration..."

# Check if HPA exists with correct name
HPA_EXISTS=$(kubectl get hpa web-api-hpa -n autoscale-test -o name 2>/dev/null || echo "")

if [ -z "$HPA_EXISTS" ]; then
    echo "FAIL: HPA 'web-api-hpa' not found in namespace autoscale-test."
    exit 1
fi

# Check HPA configuration
MIN_REPLICAS=$(kubectl get hpa web-api-hpa -n autoscale-test -o jsonpath='{.spec.minReplicas}' 2>/dev/null || echo "0")
MAX_REPLICAS=$(kubectl get hpa web-api-hpa -n autoscale-test -o jsonpath='{.spec.maxReplicas}' 2>/dev/null || echo "0")
TARGET_REF=$(kubectl get hpa web-api-hpa -n autoscale-test -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null || echo "")

# Check CPU target (could be in metrics array)
CPU_TARGET=$(kubectl get hpa web-api-hpa -n autoscale-test -o jsonpath='{.spec.metrics[?(@.type=="Resource")].resource.target.averageUtilization}' 2>/dev/null || echo "")
# Fallback for older HPA format
if [ -z "$CPU_TARGET" ]; then
    CPU_TARGET=$(kubectl get hpa web-api-hpa -n autoscale-test -o jsonpath='{.spec.targetCPUUtilizationPercentage}' 2>/dev/null || echo "")
fi

echo "HPA Configuration:"
echo "  Min replicas: $MIN_REPLICAS (expected: 2)"
echo "  Max replicas: $MAX_REPLICAS (expected: 10)"
echo "  Target ref: $TARGET_REF (expected: web-api)"
echo "  CPU target: $CPU_TARGET% (expected: 50)"

ERRORS=0

if [ "$MIN_REPLICAS" != "2" ]; then
    echo "FAIL: minReplicas should be 2, got $MIN_REPLICAS"
    ERRORS=$((ERRORS + 1))
fi

if [ "$MAX_REPLICAS" != "10" ]; then
    echo "FAIL: maxReplicas should be 10, got $MAX_REPLICAS"
    ERRORS=$((ERRORS + 1))
fi

if [ "$TARGET_REF" != "web-api" ]; then
    echo "FAIL: scaleTargetRef should be web-api, got $TARGET_REF"
    ERRORS=$((ERRORS + 1))
fi

if [ "$CPU_TARGET" != "50" ]; then
    echo "FAIL: CPU target should be 50%, got $CPU_TARGET%"
    ERRORS=$((ERRORS + 1))
fi

if [ "$ERRORS" -eq 0 ]; then
    echo "SUCCESS: HPA configured correctly!"
    exit 0
else
    echo "FAIL: HPA has $ERRORS configuration error(s)."
    exit 1
fi
