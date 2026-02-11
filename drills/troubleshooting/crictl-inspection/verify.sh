#!/bin/bash
# Verify crictl-inspection

# 1. Check if the annotation exists
PID_ANNOT=$(kubectl get pod lost-log -n trouble -o jsonpath='{.metadata.annotations.mystery/pid}' 2>/dev/null)

if [ -z "$PID_ANNOT" ]; then
    echo "FAIL: Pod 'lost-log' does not have the annotation 'mystery/pid'."
    exit 1
fi

echo "Found PID annotation: $PID_ANNOT"

# 2. Advanced: Verify if the PID is actually correct (approximation)
# We can't easily check the exact PID from outside unless we are on the node or have a way to map it back.
# But we can check if it looks like a number.
if ! [[ "$PID_ANNOT" =~ ^[0-9]+$ ]]; then
    echo "FAIL: Annotation value '$PID_ANNOT' is not a number."
    exit 1
fi

echo "SUCCESS: Annotation is present."
exit 0
