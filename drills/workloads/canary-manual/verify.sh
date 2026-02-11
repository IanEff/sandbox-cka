#!/bin/bash
set -e
NS="canary-ops"

# 1. Validate Total Pods
MAIN_REPLICAS=$(kubectl get deploy main-deploy -n $NS -o jsonpath='{.spec.replicas}')
CANARY_REPLICAS=$(kubectl get deploy canary-deploy -n $NS -o jsonpath='{.spec.replicas}')
TOTAL=$((MAIN_REPLICAS + CANARY_REPLICAS))

if [[ "$TOTAL" -ne 10 ]]; then
  echo "FAIL: Total replicas is $TOTAL. Expected 10."
  exit 1
fi

# 2. Validate Ratio (20% Canary)
# 10 * 0.20 = 2
if [[ "$CANARY_REPLICAS" -ne 2 ]]; then
  echo "FAIL: Canary replicas is $CANARY_REPLICAS. Expected 2 (20% of 10)."
  exit 1
fi

# 3. Validate Selectors
# Check if canary pod has labels matching service selector (app=main)
CANARY_LABELS=$(kubectl get deploy canary-deploy -n $NS -o jsonpath='{.spec.template.metadata.labels}')
if [[ "$CANARY_LABELS" != *"\"app\":\"main\""* ]]; then
  echo "FAIL: Canary deployment does not have 'app=main' label to match Service."
  exit 1
fi

# 4. Check Image
IMG=$(kubectl get deploy canary-deploy -n $NS -o jsonpath='{.spec.template.spec.containers[0].image}')
if [[ "$IMG" != *"nginx:1.27-alpine"* ]]; then
    echo "FAIL: Canary image is $IMG. Expected nginx:1.27-alpine."
    exit 1
fi

echo "SUCCESS: Manual canary configured correctly (8 main / 2 canary)"
exit 0
