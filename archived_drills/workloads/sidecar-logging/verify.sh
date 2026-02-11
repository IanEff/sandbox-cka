#!/bin/bash

# Check if Pod exists
if ! kubectl get pod web-server > /dev/null 2>&1; then
  echo "Pod web-server not found."
  exit 1
fi

# Check for sidecar container presence
SIDECAR=$(kubectl get pod web-server -o jsonpath='{.spec.containers[?(@.name=="log-shipper")].name}')
if [ "$SIDECAR" != "log-shipper" ]; then
  echo "Sidecar container 'log-shipper' not found."
  exit 1
fi

# Check volume mount in sidecar
MOUNT=$(kubectl get pod web-server -o jsonpath='{.spec.containers[?(@.name=="log-shipper")].volumeMounts[?(@.name=="log-vol")].mountPath}')
if [ "$MOUNT" != "/var/log" ]; then
    # Relaxed check: maybe they mounted it elsewhere, but problem implied simple access. 
    # Actually, as long as they can read the file. But standard practice is to mount it.
    echo "Volume 'log-vol' not mounted correctly in sidecar."
    exit 1
fi

# Check if sidecar is running command to tail logs
# It's hard to check exact args, but we can check if it's running.
STATUS=$(kubectl get pod web-server -o jsonpath='{.status.containerStatuses[?(@.name=="log-shipper")].state.running.startedAt}')
if [ -z "$STATUS" ]; then
    echo "Sidecar container is not running."
    exit 1
fi

echo "Pod found with sidecar log-shipper."
exit 0
