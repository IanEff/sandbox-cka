#!/bin/bash

# Ensure output directory exists
mkdir -p /opt/course/2
chmod 777 /opt/course/2
rm -f /opt/course/2/id.txt

# Clean up existing pod
kubectl delete pod secure-pod --ignore-not-found
