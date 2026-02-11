#!/bin/bash

# Check namespace exists
if ! kubectl get namespace web &>/dev/null; then
  echo "ERROR: Namespace web not found"
  exit 1
fi

# Check TLS secret exists
if ! kubectl get secret webapp-tls-cert -n web &>/dev/null; then
  echo "ERROR: Secret webapp-tls-cert not found in web namespace"
  exit 1
fi

# Verify secret is of type TLS
SECRET_TYPE=$(kubectl get secret webapp-tls-cert -n web -o jsonpath='{.type}')
if [[ "$SECRET_TYPE" != "kubernetes.io/tls" ]]; then
  echo "ERROR: Secret is not of type kubernetes.io/tls (found: $SECRET_TYPE)"
  exit 1
fi

# Check secret has required keys
if ! kubectl get secret webapp-tls-cert -n web -o jsonpath='{.data.tls\.crt}' | grep -q "."; then
  echo "ERROR: Secret missing tls.crt"
  exit 1
fi

if ! kubectl get secret webapp-tls-cert -n web -o jsonpath='{.data.tls\.key}' | grep -q "."; then
  echo "ERROR: Secret missing tls.key"
  exit 1
fi

# Check Ingress exists
if ! kubectl get ingress webapp-ingress -n web &>/dev/null; then
  echo "ERROR: Ingress webapp-ingress not found"
  exit 1
fi

# Verify Ingress has TLS configuration
if ! kubectl get ingress webapp-ingress -n web -o yaml | grep -q "tls:"; then
  echo "ERROR: Ingress does not have TLS configuration"
  exit 1
fi

# Verify TLS secret is referenced in Ingress
if ! kubectl get ingress webapp-ingress -n web -o yaml | grep -q "webapp-tls-cert"; then
  echo "ERROR: Ingress does not reference webapp-tls-cert"
  exit 1
fi

# Verify host is configured in TLS section
if ! kubectl get ingress webapp-ingress -n web -o jsonpath='{.spec.tls[*].hosts[*]}' | grep -q "webapp.example.com"; then
  echo "ERROR: Host webapp.example.com not configured in TLS section"
  exit 1
fi

echo "SUCCESS: Ingress configured with TLS using secret webapp-tls-cert"
exit 0
