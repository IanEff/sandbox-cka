#!/bin/bash
set -e

# Verification Script

# 1. Check Pod Running
STATUS=$(kubectl get pod override-pod -o jsonpath='{.status.phase}')
if [ "$STATUS" != "Running" ]; then
    echo "FAIL: Pod status is $STATUS, expected Running"
    exit 1
fi

# 2. Check Command Override
# Needs to have command: ["sleep", "3600"] or command: ["sleep"] args: ["3600"]?
# Problem said "override ENTRYPOINT to run sleep 3600".
# In K8s, 'command' overrides ENTRYPOINT.
# So we expect .spec.containers[0].command to be present.

CMD=$(kubectl get pod override-pod -o jsonpath='{.spec.containers[0].command}')
if [[ "$CMD" != *"sleep"* ]]; then
    echo "FAIL: Pod command is $CMD, expected it to contain 'sleep'"
    exit 1
fi

echo "SUCCESS: Entrypoint override drill passed."
