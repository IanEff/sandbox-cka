#!/bin/bash
NS="gateway-drill"

# 1. Check if HTTPRoute exists
if ! kubectl get httproute color-route -n $NS > /dev/null 2>&1; then
  echo "HTTPRoute 'color-route' not found in namespace '$NS'."
  exit 1
fi

# 2. Check ParentRef (Gateway name)
PARENT_GATEWAY=$(kubectl get httproute color-route -n $NS -o jsonpath='{.spec.parentRefs[0].name}')
if [[ "$PARENT_GATEWAY" != "main-gateway" ]]; then
  echo "HTTPRoute does not attach to 'main-gateway'. Attach it to the correct Gateway."
  exit 1
fi

# 3. Check Hostname
HOSTNAME=$(kubectl get httproute color-route -n $NS -o jsonpath='{.spec.hostnames[0]}')
if [[ "$HOSTNAME" != "colors.example.com" ]]; then
  echo "Hostname is incorrect. Expected 'colors.example.com', got '$HOSTNAME'."
  exit 1
fi

# 4. Check BackendRef (Service name)
SERVICE_NAME=$(kubectl get httproute color-route -n $NS -o jsonpath='{.spec.rules[0].backendRefs[0].name}')
if [[ "$SERVICE_NAME" != "color-service" ]]; then
  echo "Backend service is incorrect. Expected 'color-service', got '$SERVICE_NAME'."
  exit 1
fi

echo "Grace and glory! The Route is correct."
exit 0
