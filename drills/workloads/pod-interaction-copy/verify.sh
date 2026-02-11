#!/bin/bash
# Verify for pod-interaction-copy

POD="data-collector"

# Check file content inside Pod
CONTENT=$(kubectl exec $POD -- cat /tmp/config.txt 2>/dev/null)

if [[ "$CONTENT" != *"parameters=valid"* ]]; then
    echo "FAIL: content of /tmp/config.txt is '$CONTENT', expected 'parameters=valid'"
    exit 1
fi

echo "SUCCESS: File copied correctly."
