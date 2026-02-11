#!/bin/bash
# Check if file exists and has content
kubectl exec -n security-drill api-client -- cat /tmp/pods.json > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "File /tmp/pods.json not found in pod api-client."
    exit 1
fi

# Check if it looks like pod list
CONTENT=$(kubectl exec -n security-drill api-client -- cat /tmp/pods.json)
echo "$CONTENT" | grep "items" > /dev/null
if [ $? -ne 0 ]; then
    echo "File content does not look like a PodList (missing 'items')."
    exit 1
fi

exit 0
