#!/bin/bash
set -e

# Check if startupProbe is defined with correct values
PROBE_PERIOD=$(kubectl get deploy legacy-app -o jsonpath='{.spec.template.spec.containers[0].startupProbe.periodSeconds}')
PROBE_FAILURE=$(kubectl get deploy legacy-app -o jsonpath='{.spec.template.spec.containers[0].startupProbe.failureThreshold}')

if [ "$PROBE_PERIOD" != "5" ]; then
    echo "FAIL: Startup Probe periodSeconds is not 5. Found: $PROBE_PERIOD"
    exit 1
fi

if [ "$PROBE_FAILURE" != "15" ]; then
    echo "FAIL: Startup Probe failureThreshold is not 15. Found: $PROBE_FAILURE"
    exit 1
fi

# Determine if pod becomes ready.
# It should take at least 40s to become ready, but NOT restart.
echo "Waiting for pod to be ready (up to 90s)..."
kubectl wait --for=condition=ready pod -l app=legacy-app --timeout=90s > /dev/null

# Check restart count. Should be 0 if the startup probe protected it.
# (Note: might need a bit of leeway if user took a while to apply, but setup creates a crashing pod immediately)
# Actually, the user modifies the deployment, which triggers a NEW ReplicaSet.
# So the new pod should have 0 restarts.
RESTARTS=$(kubectl get pod -l app=legacy-app -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}')

if [ "$RESTARTS" -gt "0" ]; then
    echo "FAIL: Pod has restarted $RESTARTS times. Startup Probe failed to protect it."
    exit 1
fi

echo "SUCCESS: Startup Probe configured correctly and Pod is Ready."
