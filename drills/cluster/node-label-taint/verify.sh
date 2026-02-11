#!/bin/bash
# Verify for node-label-taint

NODE="ubukubu-node-1"

# Check Label
LBL=$(kubectl get node $NODE -o jsonpath='{.metadata.labels.hardware}')
if [ "$LBL" != "gpu" ]; then
    echo "FAIL: Label hardware=gpu missing (found '$LBL')"
    exit 1
fi

# Check Taint
# We look for the taint in the json list
TAINT=$(kubectl get node $NODE -o json | jq '.spec.taints[] | select(.key=="dedicated" and .value=="rendering" and .effect=="NoSchedule")')

if [ -z "$TAINT" ]; then
    echo "FAIL: Taint dedicated=rendering:NoSchedule missing."
    exit 1
fi

echo "SUCCESS: Node labelled and tainted."
