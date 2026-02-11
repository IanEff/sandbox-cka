#!/bin/bash

# 1. Check maxSkew
MAX_SKEW=$(kubectl get deployment spread-deploy -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].maxSkew}')
if [ "$MAX_SKEW" != "1" ]; then
  echo "FAIL: maxSkew is not 1 (found $MAX_SKEW)"
  exit 1
fi

# 2. Check topologyKey
KEY=$(kubectl get deployment spread-deploy -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].topologyKey}')
if [ "$KEY" != "kubernetes.io/hostname" ]; then
  echo "FAIL: topologyKey is not kubernetes.io/hostname (found $KEY)"
  exit 1
fi

# 3. Check whenUnsatisfiable
POLICY=$(kubectl get deployment spread-deploy -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].whenUnsatisfiable}')
if [ "$POLICY" != "DoNotSchedule" ]; then
    echo "FAIL: whenUnsatisfiable is not DoNotSchedule (found $POLICY)"
    exit 1
fi

echo "SUCCESS: Topology Spread Constraint configured correctly."
