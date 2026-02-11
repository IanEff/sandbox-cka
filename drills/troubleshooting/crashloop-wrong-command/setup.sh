#!/bin/bash
kubectl delete pod cmd-pod --ignore-not-found
kubectl run cmd-pod --image=busybox --command -- /bin/sleepytime 3600
