#!/bin/bash
kubectl get pod ssd-pod -o json | jq -e '.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0] | select(.key == "disk" and .values[0] == "ssd" and .operator == "In")' > /dev/null
