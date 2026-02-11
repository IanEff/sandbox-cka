#!/bin/bash
NS="scheduling-drill"

# Check Pod Running
POD_STATUS=$(kubectl get pods -l app=important-work -n $NS -o jsonpath='{.items[0].status.phase}')

if [[ "$POD_STATUS" != "Running" ]]; then
  echo "Pod is $POD_STATUS. Did you label the node?"
  exit 1
fi

echo "Pod scheduled successfully."
exit 0
