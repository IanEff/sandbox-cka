#!/bin/bash
NS="trouble"
DEPLOY="broken-app"

# Check ConfigMap first
CMD=$(kubectl get cm app-config -n $NS -o jsonpath='{.data.DB_URL}')
if [[ "$CMD" != "postgres://db:5432" ]]; then
  echo "FAIL: ConfigMap app-config missing correct DB_URL key/value"
  exit 1
fi

# Check Pod Status
# Get pod name from deployment
POD=$(kubectl get pod -l app=broken-app -n $NS -o jsonpath='{.items[0].metadata.name}')

if [[ -z "$POD" ]]; then
  echo "FAIL: No pods found for deployment"
  exit 1
fi

STATUS=$(kubectl get pod $POD -n $NS -o jsonpath='{.status.phase}')
if [[ "$STATUS" != "Running" ]]; then
  echo "FAIL: Pod $POD is $STATUS, expected Running"
  exit 1
fi

# Check Logs for success message
if ! kubectl logs $POD -n $NS | grep -q "Connected to postgres://db:5432"; then
  echo "FAIL: Logs do not show successful connection string. Did you restart the pod?"
  exit 1
fi

echo "SUCCESS: Pod fixed."
exit 0
