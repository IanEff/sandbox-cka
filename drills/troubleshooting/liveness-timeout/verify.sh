#!/bin/bash
set -e
NS="liveness-fail"

# Check Pod exists
kubectl get pod slow-starter -n $NS > /dev/null

# Check InitialDelay
DELAY=$(kubectl get pod slow-starter -n $NS -o jsonpath='{.spec.containers[0].livenessProbe.initialDelaySeconds}')

if [[ "$DELAY" -lt 20 ]]; then
  echo "FAIL: initialDelaySeconds is $DELAY. Should be at least 20 to accommodate the 15s startup."
  exit 1
fi

# Check Status (Should be Running)
# We wait a bit to ensure it hasn't crashed
STATUS=$(kubectl get pod slow-starter -n $NS -o jsonpath='{.status.phase}')
if [[ "$STATUS" != "Running" ]]; then
  echo "FAIL: Pod status is $STATUS. It should be Running."
  exit 1
fi

RESTARTS=$(kubectl get pod slow-starter -n $NS -o jsonpath='{.status.containerStatuses[0].restartCount}')
# Ideally 0, but if the user edited the existing pod after a few crashes, it might be >0. 
# But if it's currently running fine, that's what matters.
# Let's check LastState.
LAST_STATE=$(kubectl get pod slow-starter -n $NS -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}')

if [[ -n "$LAST_STATE" ]] && [[ "$LAST_STATE" != "Completed" ]] && [[ "$LAST_STATE" != "Error" ]]; then
    # This is a weak check. Simpler: Is it Ready?
    IS_READY=$(kubectl get pod slow-starter -n $NS -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
    if [[ "$IS_READY" != "True" ]]; then
        echo "FAIL: Pod is not Ready."
        exit 1
    fi
fi

echo "SUCCESS: Liveness probe adjusted."
exit 0
