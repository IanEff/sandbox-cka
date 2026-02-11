#!/usr/bin/env bash
set -e

# 1. Check if Pod is Running on the correct node
NODE_NAME=$(kubectl get pod crisis-aversion -o jsonpath='{.spec.nodeName}')
PHASE=$(kubectl get pod crisis-aversion -o jsonpath='{.status.phase}')

if [[ "$NODE_NAME" != "ubukubu-node-1" ]]; then
    echo "FAIL: Pod 'crisis-aversion' is not scheduled on 'ubukubu-node-1' (Found: $NODE_NAME)"
    exit 1
fi

if [[ "$PHASE" != "Running" ]]; then
    echo "FAIL: Pod 'crisis-aversion' is not Running (Found: $PHASE)"
    exit 1
fi

# 2. Check if Scheduler is back running
if [ ! -f /etc/kubernetes/manifests/kube-scheduler.yaml ]; then
     echo "FAIL: kube-scheduler manifest not found in /etc/kubernetes/manifests/. Did you restart it?"
     exit 1
fi

echo "Checking scheduler health..."
# Allow some time for it to come back
timeout 30 bash -c 'until kubectl get pods -n kube-system -l component=kube-scheduler 2>/dev/null | grep -q "Running"; do sleep 1; done'

echo "SUCCESS: Pod manually scheduled and scheduler restored."
