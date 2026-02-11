#!/bin/bash
# cluster/maintenance-node-drain/setup.sh
# Creates a deployment and ensures it lands on the node to be drained

kubectl create deployment drain-test --image=nginx:alpine --replicas=3 --dry-run=client -o yaml | kubectl apply -f -
kubectl label node ubukubu-node-1 failure-domain.beta.kubernetes.io/zone=primary --overwrite

# Force scheduling onto node-1 temporarily or just let it balance, 
# but specifically taint or affinity might be too much.
# Let's just cordon node-2 so they HAVE to land on node-1, then uncordon node-2?
# No, let's just make sure node-1 is ready and schedulable.
kubectl uncordon ubukubu-node-1 2>/dev/null || true
