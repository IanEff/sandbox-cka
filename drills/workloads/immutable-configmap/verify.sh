#!/bin/bash
# Verify for immutable-configmap

# Check Immutable Field
immutable=$(kubectl get cm locked-config -n config-test -o jsonpath='{.immutable}')

if [ "$immutable" != "true" ]; then
    echo "ConfigMap locked-config is not set to immutable: true"
    exit 1
fi

# Check Data
data=$(kubectl get cm locked-config -n config-test -o jsonpath='{.data.max_connections}')
if [ "$data" != "100" ]; then
    echo "ConfigMap data incorrect. Expected 100, got $data"
    exit 1
fi

# Check Pod Mount
# Just verify the pod exists and has the volume.
vol_name=$(kubectl get pod consumer -n config-test -o jsonpath='{.spec.volumes[?(@.configMap.name=="locked-config")].name}')
if [ -z "$vol_name" ]; then
    echo "Pod consumer does not mount the configmap."
    exit 1
fi

echo "ConfigMap is immutable and mounted."
exit 0
