#!/bin/bash
# Verify DaemonSet All Nodes Drill
set -e

NS="monitoring"

# Check DaemonSet exists
if ! kubectl get daemonset log-collector -n $NS >/dev/null 2>&1; then
    echo "FAIL: DaemonSet 'log-collector' not found in namespace $NS"
    exit 1
fi

# Check labels
LABELS=$(kubectl get daemonset log-collector -n $NS -o jsonpath='{.spec.template.metadata.labels}')
if [[ "$LABELS" != *"app"*"log-collector"* ]]; then
    echo "FAIL: DaemonSet pods missing label app=log-collector"
    exit 1
fi
echo "PASS: Labels correct"

# Check resource requests
CPU=$(kubectl get daemonset log-collector -n $NS -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
MEM=$(kubectl get daemonset log-collector -n $NS -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')
if [[ "$CPU" != "10m" ]] || [[ "$MEM" != "20Mi" ]]; then
    echo "FAIL: Resource requests incorrect (cpu=$CPU, memory=$MEM)"
    exit 1
fi
echo "PASS: Resource requests correct"

# Count nodes and desired pods
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l | tr -d ' ')
DESIRED=$(kubectl get daemonset log-collector -n $NS -o jsonpath='{.status.desiredNumberScheduled}')
READY=$(kubectl get daemonset log-collector -n $NS -o jsonpath='{.status.numberReady}')

echo "Nodes: $NODE_COUNT, Desired: $DESIRED, Ready: $READY"

if [[ "$DESIRED" != "$NODE_COUNT" ]]; then
    echo "FAIL: DaemonSet desired ($DESIRED) does not match node count ($NODE_COUNT)"
    echo "Hint: Did you add a toleration for the control-plane taint?"
    exit 1
fi

# Wait for pods to be ready
timeout 60 bash -c "until [[ \$(kubectl get daemonset log-collector -n $NS -o jsonpath='{.status.numberReady}') == '$NODE_COUNT' ]]; do sleep 2; done" || {
    echo "FAIL: Not all DaemonSet pods became ready"
    exit 1
}

# Verify pod on control plane
CP_NODE=$(kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers -o custom-columns=NAME:.metadata.name | head -1)
POD_ON_CP=$(kubectl get pods -n $NS -l app=log-collector --field-selector spec.nodeName=$CP_NODE --no-headers | wc -l | tr -d ' ')

if [[ "$POD_ON_CP" -lt 1 ]]; then
    echo "FAIL: No log-collector pod running on control plane node $CP_NODE"
    exit 1
fi
echo "PASS: Pod running on control plane"

echo "SUCCESS: DaemonSet deployed on all nodes including control plane"
