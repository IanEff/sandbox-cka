#!/bin/bash

WORKER_NODE=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$WORKER_NODE" ]; then
    echo "ERROR: No worker nodes found."
    exit 1
fi

STATUS=$(kubectl get node "$WORKER_NODE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')

if [ "$STATUS" == "True" ]; then
    echo "Node $WORKER_NODE is Ready."
    exit 0
else
    echo "Node $WORKER_NODE is NOT Ready (Status: $STATUS)."
    exit 1
fi
