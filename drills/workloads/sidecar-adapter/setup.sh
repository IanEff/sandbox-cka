#!/bin/bash
kubectl delete ns adapter-drill --ignore-not-found
kubectl create ns adapter-drill

# Create the initial pod manifest (user needs to retrieve it or edit it)
# We deploy it so they can see the running state, but they'll likely delete/recreate
kubectl run logger --image=busybox --restart=Never -n adapter-drill \
  --overrides='{"spec": {"containers": [{"name": "main", "image": "busybox", "command": ["/bin/sh", "-c", "mkdir -p /var/log && while true; do date >> /var/log/main.log; sleep 1; done"]}]}}'

echo "Pod logger created in adapter-drill."
