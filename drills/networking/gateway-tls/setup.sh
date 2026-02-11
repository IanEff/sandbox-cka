#!/bin/bash
# Namespace
kubectl create ns gateway-tls --dry-run=client -o yaml | kubectl apply -f -

# Generate Self-Signed Cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=secure.test" 2>/dev/null

# Create Secret
kubectl create secret tls secure-cert -n gateway-tls --key /tmp/tls.key --cert /tmp/tls.crt --dry-run=client -o yaml | kubectl apply -f -
rm /tmp/tls.key /tmp/tls.crt

# Clean up Gateway
kubectl delete gateway secure-gw -n gateway-tls --ignore-not-found
