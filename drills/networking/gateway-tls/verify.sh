#!/bin/bash
set -e

GW_NAME="secure-gw"
NS="gateway-tls"

# Check existence
kubectl get gateway $GW_NAME -n $NS > /dev/null

# Check Class
CLASS=$(kubectl get gateway $GW_NAME -n $NS -o jsonpath='{.spec.gatewayClassName}')
if [[ "$CLASS" != "cilium" ]]; then
    echo "FAIL: GatewayClass is $CLASS, expected cilium"
    exit 1
fi

# Check Listener
LISTENER=$(kubectl get gateway $GW_NAME -n $NS -o json | jq '.spec.listeners[] | select(.name=="https-1")')

if [[ -z "$LISTENER" ]]; then
    echo "FAIL: Listener 'https-1' not found"
    exit 1
fi

# Check Port/Proto
PORT=$(echo $LISTENER | jq -r .port)
PROTO=$(echo $LISTENER | jq -r .protocol)
HOST=$(echo $LISTENER | jq -r .hostname)
CERT=$(echo $LISTENER | jq -r .tls.certificateRefs[0].name)

if [[ "$PORT" != "443" ]] || [[ "$PROTO" != "HTTPS" ]]; then
    echo "FAIL: Port/Protocol mismatch. Got $PORT/$PROTO"
    exit 1
fi

if [[ "$HOST" != "secure.test" ]]; then
    echo "FAIL: Hostname mismatch. Got $HOST"
    exit 1
fi

if [[ "$CERT" != "secure-cert" ]]; then
    echo "FAIL: CertificateRef mismatch. Got $CERT"
    exit 1
fi

echo "SUCCESS: Gateway TLS listener configured correctly"
exit 0
