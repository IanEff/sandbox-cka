#!/bin/bash

# Cleanup
kubectl delete pod castaway --force --grace-period=0 2>/dev/null || true
kubectl delete svc sos-signal --force --grace-period=0 2>/dev/null || true

# The Castaway
kubectl run castaway --image=nginx --restart=Always --labels=id=wilson

# The Bottle (Service with wrong selector)
kubectl create service clusterip sos-signal --tcp=80:80
# Patch selector to be wrong
kubectl patch svc sos-signal --type='json' -p='[{"op": "replace", "path": "/spec/selector", "value": {"id": "chuck"}}]'

kubectl wait --for=condition=Ready pod/castaway --timeout=60s
