#!/bin/bash

# 1. Check if node is cordoned (SchedulingDisabled)
STATUS=$(kubectl get node ubukubu-node-1 -o jsonpath='{.spec.unschedulable}')
if [ "$STATUS" != "true" ]; then
    echo "FAIL: Node ubukubu-node-1 is not cordoned (unschedulable is '$STATUS')"
    exit 1
fi

# 2. Check if the test pod is gone from that node
# Since we used a naked pod with nodeName, it won't be rescheduled elsewhere (no controller).
# Draining it should delete it.
if kubectl get pod maintenance-test-pod > /dev/null 2>&1; then
    # It still exists? Maybe it wasn't evicted.
    # Check if it's still running? Draining usually deletes naked pods.
    echo "FAIL: maintenance-test-pod still exists. Did you drain correctly?"
    exit 1
fi

# 3. Check if there are ANY non-daemonset pods typically?
# That's hard to verify generically in a shared cluster.
# The previous check is usually sufficient for the "drain" action validation on a specific test pod.

echo "SUCCESS: Node is cordoned and test pod evicted."
