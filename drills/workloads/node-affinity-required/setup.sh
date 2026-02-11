#!/bin/bash
kubectl delete pod ssd-pod --ignore-not-found
# Ensure no nodes have the label to start with, or maybe label one to be helpful?
# Let's verify simply checks spec, so cleaning up labels is good practice but might interrupt other drills.
# We'll just delete the pod.
