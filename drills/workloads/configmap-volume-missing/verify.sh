#!/bin/bash
# workloads/configmap-volume-missing/verify.sh

# 1. Check ConfigMap exists
if ! kubectl get cm missing-map >/dev/null 2>&1; then
    echo "FAIL: ConfigMap 'missing-map' still missing."
    exit 1
fi

# 2. Check content
VAL=$(kubectl get cm missing-map -o jsonpath='{.data.game\.properties}')
if [ "$VAL" != "enemies=aliens" ]; then
    echo "FAIL: ConfigMap content incorrect (found '$VAL')."
    exit 1
fi

# 3. Check Pod Running
# Kubelet syncs may take a minute if it backed off
if ! kubectl wait --for=condition=ready pod/broken-config --timeout=15s >/dev/null 2>&1; then
    # Sometimes it needs a kick if it's in a deep backoff
    # But usually creating the CM is enough.
    echo "FAIL: Pod 'broken-config' not ready."
    exit 1
fi

echo "SUCCESS: ConfigMap created and Pod running."
