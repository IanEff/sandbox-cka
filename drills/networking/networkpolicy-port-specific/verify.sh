#!/bin/bash
DB_IP=$(kubectl get pod database -n restricted-net -o jsonpath='{.status.podIP}')
CLIENT_POD=$(kubectl get pod client -n restricted-net -o jsonpath='{.metadata.name}')

# Check Allow
kubectl exec -n restricted-net "$CLIENT_POD" -- timeout 2 nc -zv "$DB_IP" 6379
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "Connection to 6379 failed."
    exit 1
fi

# Check Policy Config for correct port
PORT_CHECK=$(kubectl get netpol allow-db-port -n restricted-net -o jsonpath='{.spec.ingress[0].ports[0].port}')
if [ "$PORT_CHECK" != "6379" ]; then
    echo "NetworkPolicy does not specify port 6379."
    # Check if they used string or int? 6379
    exit 1
fi

exit 0
