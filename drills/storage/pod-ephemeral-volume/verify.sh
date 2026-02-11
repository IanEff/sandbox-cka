#!/bin/bash
# Verify for pod-ephemeral-volume

POD="temp-store"

# Check if volume is present and is ephemeral
VOL_SRC=$(kubectl get pod $POD -o jsonpath='{.spec.volumes[?(@.name=="scratch-vol")]}')

if [[ "$VOL_SRC" != *"ephemeral"* ]]; then
    echo "FAIL: Volume scratch-vol is not ephemeral or missing."
    exit 1
fi

echo "SUCCESS: Ephemeral volume configured."
