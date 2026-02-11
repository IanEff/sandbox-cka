#!/bin/bash
NS="rbac-4"
SA="system:serviceaccount:$NS:pod-viewer"

# Check Allowed
kubectl auth can-i list pods -n $NS --as $SA | grep "yes" || exit 1
kubectl auth can-i get pods -n $NS --as $SA | grep "yes" || exit 1
kubectl auth can-i get pods/log -n $NS --as $SA | grep "yes" || exit 1

# Check Denied
kubectl auth can-i delete pods -n $NS --as $SA | grep "no" || exit 1
kubectl auth can-i create secrets -n $NS --as $SA | grep "no" || exit 1
# Check logs watching (optional based on interpretation, but 'get' logs is usually subresource)
