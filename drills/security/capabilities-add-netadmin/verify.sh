#!/bin/bash
# Verify for capabilities-add-netadmin

POD="net-master"

# JSONPath might return a list [NET_ADMIN]
CAPS=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].securityContext.capabilities.add}')

if [[ "$CAPS" != *"NET_ADMIN"* ]]; then
    echo "FAIL: Capabilities added are '$CAPS', expected to include 'NET_ADMIN'"
    exit 1
fi

# Also check it is running (implies admissable)
STATUS=$(kubectl get pod $POD -o jsonpath='{.status.phase}')
if [ "$STATUS" == "Failed" ]; then
     echo "FAIL: Pod failed to start."
     exit 1
fi

echo "SUCCESS: Capability added."
