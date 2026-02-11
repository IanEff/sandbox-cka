#!/bin/bash
# Verify for helm-install-chart

# Check namespace
kubectl get ns neon-city >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Namespace neon-city not found"
    exit 1
fi

# Check release
helm list -n neon-city | grep neon-gateway >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Helm release neon-gateway not found"
    exit 1
fi

# Check replicas (Chart defaults to 1 usually, we asked for 2)
# Assuming the chart creates a deployment. I need to be sure mychart creates a deployment.
# If mychart is generic scaffold, it usually does.
count=$(kubectl get deploy -n neon-city -l app.kubernetes.io/instance=neon-gateway -o jsonpath='{.items[0].spec.replicas}')
if [ "$count" != "2" ]; then
    echo "Expected 2 replicas, found $count"
    exit 1
fi

echo "Drill passed!"
exit 0
