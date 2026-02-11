#!/bin/bash
# Verify for env-from-aggregation

# Get Pod JSON
JSON=$(kubectl get pod aggregator -n env-mix -o json)

# Check Secret Ref (No Prefix)
SECRET_REF=$(echo "$JSON" | jq -r '.spec.containers[0].envFrom[] | select(.secretRef.name == "app-secrets")')
if [ -z "$SECRET_REF" ]; then
    echo "Secret app-secrets not used in envFrom."
    exit 1
fi

# Check ConfigMap Ref (With Prefix)
CM_REF=$(echo "$JSON" | jq -r '.spec.containers[0].envFrom[] | select(.configMapRef.name == "app-settings")')
if [ -z "$CM_REF" ]; then
    echo "ConfigMap app-settings not used in envFrom."
    exit 1
fi

PREFIX=$(echo "$CM_REF" | jq -r '.prefix')
if [ "$PREFIX" != "CONF_" ]; then
    echo "ConfigMap prefix incorrect. Expected CONF_, found $PREFIX"
    exit 1
fi

echo "Environment aggregation configured correctly."
exit 0
