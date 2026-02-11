#!/bin/bash
NS="public-access"

# 1. Check NodePort value
PORT=$(kubectl get svc echo-nodeport -n $NS -o jsonpath='{.spec.ports[0].nodePort}')
if [ "$PORT" != "30050" ]; then
    echo "FAIL: NodePort is $PORT, expected 30050"
    exit 1
fi

# 2. Check connectivity
# Get IP of a node (control-plane usually reachable in this sandbox)
NODE_IP=$(kubectl get node -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Use timeout to prevent hanging
timeout 2 nc -z -v $NODE_IP 30050
if [ $? -ne 0 ]; then
    echo "FAIL: Cannot connect to $NODE_IP:30050"
    exit 1
fi

echo "Verification success"
exit 0
