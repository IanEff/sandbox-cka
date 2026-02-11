#!/bin/bash
NS="ds-drill"

# Count Nodes
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)

# Count Pods
POD_COUNT=$(kubectl get pods -n $NS -l name=ds-all --no-headers 2>/dev/null | wc -l)
# If label is different, try generic select all in NS if only one DS exists
# Or user might not label it 'name=ds-all'. Let's match all pods owned by DS
DS_UID=$(kubectl get ds ds-all -n $NS -o jsonpath='{.metadata.uid}')
POD_COUNT=$(kubectl get pods -n $NS -o jsonpath="{.items[?(@.metadata.ownerReferences[0].uid=='$DS_UID')].metadata.name}" | wc -w)

if [ "$POD_COUNT" -ne "$NODE_COUNT" ]; then
  echo "Expected $NODE_COUNT pods, found $POD_COUNT"
  exit 1
fi

echo "DaemonSet running on all nodes."
exit 0
