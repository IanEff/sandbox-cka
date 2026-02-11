#!/bin/bash
# Verify for pod-image-pull-error

POD="typo-pod"

# Check Status
STATUS=$(kubectl get pod $POD -o jsonpath='{.status.phase}')
if [ "$STATUS" != "Running" ]; then
    echo "FAIL: Pod status is $STATUS, expected Running."
    exit 1
fi

# Double check image fix
IMG=$(kubectl get pod $POD -o jsonpath='{.spec.containers[0].image}')
if [[ "$IMG" == *"nginxx"* ]]; then
     echo "FAIL: Image still looks wrong: $IMG"
     exit 1
fi

echo "SUCCESS: Pod is running."
