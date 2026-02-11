#!/bin/bash
# Verify for projected-volume-keys

# Check Volume Config
# Looking for .spec.volumes[].configMap.items
ITEMS_JSON=$(kubectl get pod web-server -n projection-lab -o jsonpath='{.spec.volumes[?(@.configMap.name=="nginx-custom")].configMap.items}')

if [ -z "$ITEMS_JSON" ] || [ "$ITEMS_JSON" == "[]" ]; then
    echo "No specific items projected in the volume source."
    exit 1
fi

# Check key and path
KEY=$(echo "$ITEMS_JSON" | jq -r '.[0].key')
PATH_VAL=$(echo "$ITEMS_JSON" | jq -r '.[0].path')

if [ "$KEY" != "virtualhost.conf" ]; then
    echo "Projected key is $KEY, expected virtualhost.conf"
    exit 1
fi

if [ "$PATH_VAL" != "my-site.conf" ]; then
    echo "Projected path is $PATH_VAL, expected my-site.conf"
    exit 1
fi

# Check if other items exist (Array length should be 1)
LEN=$(echo "$ITEMS_JSON" | jq 'length')
if [ "$LEN" -ne 1 ]; then
    echo "More than one item projected."
    exit 1
fi

echo "Volume projection correct."
exit 0
