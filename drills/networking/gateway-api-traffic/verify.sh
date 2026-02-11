#!/bin/bash
set -e

NS="project-r500"
GATEWAY_NAME="project-gateway"
ROUTE_NAME="traffic-director"

# Check if HTTPRoute exists
kubectl get httproute $ROUTE_NAME -n $NS > /dev/null 2>&1 || { echo "HTTPRoute not found"; exit 1; }

# Get Gateway IP (Convoy usually allocates a LoadBalancer IP, usually MetalLB)
# We wait for IP
GW_IP=""
for i in {1..30}; do
  GW_IP=$(kubectl get gateway $GATEWAY_NAME -n $NS -o jsonpath='{.status.addresses[0].value}')
  [ -n "$GW_IP" ] && break
  sleep 2
done

if [ -z "$GW_IP" ]; then
  echo "Gateway did not get an IP"
  exit 1
fi

echo "Verifying /desktop -> Nginx"
# Desktop is nginx (default page contains "Welcome to nginx")
curl -s "$GW_IP/desktop" | grep -i "nginx" || { echo "Failed /desktop check"; exit 1; }

echo "Verifying /mobile -> HTTPD"
# Mobile is httpd (default page contains "It works")
curl -s "$GW_IP/mobile" | grep -i "works" || { echo "Failed /mobile check"; exit 1; }

echo "Verifying /auto (User-Agent: mobile) -> HTTPD"
curl -s -H "User-Agent: mobile" "$GW_IP/auto" | grep -i "works" || { echo "Failed /auto mobile header check"; exit 1; }

echo "Verifying /auto (User-Agent: other) -> Nginx"
curl -s -H "User-Agent: other" "$GW_IP/auto" | grep -i "nginx" || { echo "Failed /auto default check"; exit 1; }

echo "Success!"
exit 0
