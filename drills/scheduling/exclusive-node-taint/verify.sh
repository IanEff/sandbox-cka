#!/bin/bash

# 1. Identify where the pod is running
POD_NODE=$(kubectl get pod sys-admin-pod -n scheduling-7 -o jsonpath='{.spec.nodeName}')

if [ -z "$POD_NODE" ]; then
    echo "FAIL: Pod sys-admin-pod not found or not scheduled."
    exit 1
fi

echo "Pod is running on: $POD_NODE"

# 2. Check strict label requirement on that specific node
# The drill requires matching the label 'maintenance=true'
# We check if the node hosting the pod actually has this label.
LABEL_CHECK=$(kubectl get node "$POD_NODE" -o jsonpath='{.metadata.labels.maintenance}')

if [ "$LABEL_CHECK" != "true" ]; then
    echo "FAIL: Node $POD_NODE is missing required label 'maintenance=true'."
    exit 1
fi

# 3. Check taint requirement
# The drill requires the node to be tainted.
# strict check using describe which formats taints as key=value:effect
if ! kubectl describe node "$POD_NODE" | grep "Taints:" | grep -q "maintenance=true:NoSchedule"; then
   echo "FAIL: Node $POD_NODE is missing required taint 'maintenance=true:NoSchedule'."
   # print actual taints for debugging
   echo "Actual Taints:"
   kubectl get node "$POD_NODE" -o jsonpath='{.spec.taints[*]}'
   exit 1
fi

echo "SUCCESS: Pod running on tainted/labeled node $POD_NODE"
exit 0
