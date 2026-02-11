#!/bin/bash
PC_VALUE=$(kubectl get priorityclass mission-critical -o jsonpath='{.value}' 2>/dev/null)
POD_PC=$(kubectl get pod critical-pod -o jsonpath='{.spec.priorityClassName}' 2>/dev/null)

if [[ "$PC_VALUE" == "1000000" ]] && [[ "$POD_PC" == "mission-critical" ]]; then
    exit 0
else
    echo "Check failed: PC Value=$PC_VALUE (expected 1000000), Pod PC=$POD_PC (expected mission-critical)"
    exit 1
fi
