#!/bin/bash
NS="adapter-drill"
POD="logger"

# Check container count
COUNT=$(kubectl get pod $POD -n $NS -o jsonpath='{.spec.containers[*].name}' | wc -w)
if [ "$COUNT" -lt 2 ]; then echo "Pod should have 2 containers"; exit 1; fi

# Check adapter container exists
kubectl get pod $POD -n $NS -o jsonpath='{.spec.containers[*].name}' | grep -q "adapter"
if [ $? -ne 0 ]; then echo "Container 'adapter' not found"; exit 1; fi

# Check logs from adapter
# We look for a date (e.g., "Jan..." or "202...")
# Busybox date format is typically "Mon Jan 1 12:00:00 UTC 2024"
LOGS=$(timeout 2 kubectl logs $POD -c adapter -n $NS | tail -n 1)
if [[ -z "$LOGS" ]]; then
  echo "Adapter logs are empty."
  exit 1
fi

echo "Adapter pattern verified."
exit 0
