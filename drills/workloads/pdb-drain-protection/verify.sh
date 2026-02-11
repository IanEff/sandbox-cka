#!/bin/bash
# Verify PDB Drain Protection Drill
set -e

NS="project-lima"
PDB_NAME="payment-api-pdb"
RESULT_FILE="/home/vagrant/pdb-allowed-disruptions.txt"
ERRORS=0

# 1. Check PDB exists
if ! kubectl get pdb $PDB_NAME -n $NS >/dev/null 2>&1; then
    echo "FAIL: PodDisruptionBudget '$PDB_NAME' not found in namespace $NS"
    exit 1
fi

# 2. Check PDB targets payment-api pods
SELECTOR=$(kubectl get pdb $PDB_NAME -n $NS -o jsonpath='{.spec.selector.matchLabels.app}')
if [ "$SELECTOR" != "payment-api" ]; then
    echo "FAIL: PDB selector does not match 'app: payment-api'. Got app=$SELECTOR"
    ERRORS=$((ERRORS + 1))
else
    echo "PASS: PDB selector targets app=payment-api"
fi

# 3. Check minAvailable or maxUnavailable
MIN_AVAIL=$(kubectl get pdb $PDB_NAME -n $NS -o jsonpath='{.spec.minAvailable}' 2>/dev/null)
MAX_UNAVAIL=$(kubectl get pdb $PDB_NAME -n $NS -o jsonpath='{.spec.maxUnavailable}' 2>/dev/null)

if [ "$MIN_AVAIL" = "2" ]; then
    echo "PASS: minAvailable=2"
elif [ "$MAX_UNAVAIL" = "1" ]; then
    echo "PASS: maxUnavailable=1 (equivalent to minAvailable=2 with 3 replicas)"
else
    echo "FAIL: PDB should ensure minimum 2 pods available."
    echo "  Got minAvailable='$MIN_AVAIL', maxUnavailable='$MAX_UNAVAIL'"
    ERRORS=$((ERRORS + 1))
fi

# 4. Check result file
if [ ! -f "$RESULT_FILE" ]; then
    echo "FAIL: $RESULT_FILE not found"
    ERRORS=$((ERRORS + 1))
else
    EXPECTED_DISRUPTIONS=$(kubectl get pdb $PDB_NAME -n $NS -o jsonpath='{.status.disruptionsAllowed}')
    ACTUAL=$(cat "$RESULT_FILE" | tr -d '[:space:]')
    if [ "$ACTUAL" != "$EXPECTED_DISRUPTIONS" ]; then
        echo "FAIL: Expected allowed disruptions=$EXPECTED_DISRUPTIONS, got '$ACTUAL'"
        ERRORS=$((ERRORS + 1))
    else
        echo "PASS: Allowed disruptions correctly recorded: $EXPECTED_DISRUPTIONS"
    fi
fi

echo ""
if [ $ERRORS -gt 0 ]; then
    echo "FAIL: $ERRORS error(s) found"
    exit 1
fi

echo "SUCCESS: PodDisruptionBudget correctly configured"
