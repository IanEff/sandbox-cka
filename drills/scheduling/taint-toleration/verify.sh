#!/bin/bash

# Check if running
if kubectl wait --for=condition=ready pod -l app=monitor-agent -n drill-scheduling --timeout=15s; then
    echo "Pod is Running."
else
    echo "Pod not ready."
    exit 1
fi

# Check Node (Ensure it's on control plane)
NODE=$(kubectl get pod -l app=monitor-agent -n drill-scheduling -o jsonpath='{.items[0].spec.nodeName}')
if [[ "$NODE" == "ubukubu-control" ]]; then
    echo "Correct Node."
    exit 0
else
    echo "Wrong Node: $NODE"
    exit 1
fi
