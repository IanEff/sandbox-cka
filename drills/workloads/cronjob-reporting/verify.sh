#!/bin/bash
NS="reports"
CJ="disk-checker"

# Check limits
LIMIT_S=$(kubectl get cj $CJ -n $NS -o jsonpath='{.spec.successfulJobsHistoryLimit}')
LIMIT_F=$(kubectl get cj $CJ -n $NS -o jsonpath='{.spec.failedJobsHistoryLimit}')

if [ "$LIMIT_S" != "5" ]; then echo "FAIL: successfulJobsHistoryLimit is $LIMIT_S (expected 5)"; exit 1; fi
if [ "$LIMIT_F" != "2" ]; then echo "FAIL: failedJobsHistoryLimit is $LIMIT_F (expected 2)"; exit 1; fi

# Check manual trigger job exists
kubectl get job manual-test -n $NS > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "FAIL: Job 'manual-test' not found"
    exit 1
fi

# Verify it completed
kubectl wait --for=condition=complete job/manual-test -n $NS --timeout=30s

echo "Verification success"
exit 0
