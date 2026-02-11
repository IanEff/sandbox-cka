#!/bin/bash
set -e
NS="anti-affinity"

# Get Affinity
AFFINITY=$(kubectl get deploy redis-cache -n $NS -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity}')

# Check Required
REQUIRED=$(echo $AFFINITY | jq -r '.requiredDuringSchedulingIgnoredDuringExecution[0]')

if [[ "$REQUIRED" == "null" ]]; then
  echo "FAIL: No requiredDuringSchedulingIgnoredDuringExecution anti-affinity found."
  exit 1
fi

# Check Topology
TOPOLOGY=$(echo $REQUIRED | jq -r '.topologyKey')
if [[ "$TOPOLOGY" != "kubernetes.io/hostname" ]]; then
  echo "FAIL: TopologyKey is $TOPOLOGY. Expected kubernetes.io/hostname."
  exit 1
fi

# Check Selector
SELECTOR=$(echo $REQUIRED | jq -r '.labelSelector.matchLabels.app')
if [[ "$SELECTOR" != "redis-cache" ]]; then
  echo "FAIL: LabelSelector matches '$SELECTOR'. Expected 'redis-cache'."
  exit 1
fi

echo "SUCCESS: Pod Anti-Affinity configured."
exit 0
