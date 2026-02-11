#!/bin/bash

# Clean up
kubectl delete storageclass high-iops --ignore-not-found

# Ensure standard is default (or whatever was default before, strictly speaking we might want to unset everything to make it harder, but usually there's one default)
# For this drill, we just want to make sure 'high-iops' isn't there.
