#!/bin/bash
# Validation for HPA v2 Behavior

NAME="hpa-behavior-deploy"

# Check if HPA exists
if ! kubectl get hpa $NAME > /dev/null 2>&1; then
    echo "FAIL: HPA '$NAME' not found."
    exit 1
fi

# Check Min/Max/Target
MIN=$(kubectl get hpa $NAME -o jsonpath='{.spec.minReplicas}')
MAX=$(kubectl get hpa $NAME -o jsonpath='{.spec.maxReplicas}')
TARGET=$(kubectl get hpa $NAME -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}')

if [[ "$MIN" != "1" ]]; then echo "FAIL: Min replicas is $MIN (expected 1)"; exit 1; fi
if [[ "$MAX" != "10" ]]; then echo "FAIL: Max replicas is $MAX (expected 10)"; exit 1; fi
if [[ "$TARGET" != "50" ]]; then echo "FAIL: Target CPU is $TARGET (expected 50)"; exit 1; fi

# Check Behavior
BEHAVIOR=$(kubectl get hpa $NAME -o jsonpath='{.spec.behavior.scaleDown}')
# Check if behavior is defined at all
if [[ -z "$BEHAVIOR" ]]; then
     echo "FAIL: No scaleDown behavior defined."
     exit 1
fi

STAB_WIN=$(echo "$BEHAVIOR" | jq -r '.stabilizationWindowSeconds')

# Note: Default stabilization is 300. Requirement is 60.
if [[ "$STAB_WIN" != "60" ]]; then 
    echo "FAIL: scaleDown.stabilizationWindowSeconds is $STAB_WIN (expected 60)."
    exit 1
fi

echo "SUCCESS: HPA configured correctly."
exit 0
