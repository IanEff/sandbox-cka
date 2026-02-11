#!/bin/bash

TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
DS_READY=$(kubectl get ds cluster-monitor -n workloads-8 -o jsonpath='{.status.numberReady}')

if [ "$DS_READY" -ne "$TOTAL_NODES" ]; then
    echo "FAIL: Ready pods ($DS_READY) does not match total nodes ($TOTAL_NODES)"
    exit 1
fi

echo "SUCCESS: DaemonSet running on all $TOTAL_NODES nodes"
exit 0
