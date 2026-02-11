#!/bin/bash

# Check pod is running
if ! kubectl get pod secure-app -n vault &>/dev/null; then
  echo "ERROR: Pod secure-app not found in vault namespace"
  exit 1
fi

if ! kubectl wait --for=condition=ready pod/secure-app -n vault --timeout=10s &>/dev/null; then
  echo "ERROR: Pod secure-app is not Ready"
  exit 1
fi

# Check if secret is mounted
if ! kubectl exec secure-app -n vault -- ls /etc/db-creds/username &>/dev/null; then
  echo "ERROR: Secret file /etc/db-creds/username not found"
  exit 1
fi

if ! kubectl exec secure-app -n vault -- ls /etc/db-creds/password &>/dev/null; then
  echo "ERROR: Secret file /etc/db-creds/password not found"
  exit 1
fi

# Check file permissions (should be 0400 or 0444)
USERNAME_PERMS=$(kubectl exec secure-app -n vault -- stat -L -c '%a' /etc/db-creds/username 2>/dev/null)
PASSWORD_PERMS=$(kubectl exec secure-app -n vault -- stat -L -c '%a' /etc/db-creds/password 2>/dev/null)

if [[ "$USERNAME_PERMS" != "400" ]] && [[ "$USERNAME_PERMS" != "444" ]]; then
  echo "ERROR: username file permissions are $USERNAME_PERMS (expected 400 or 444)"
  exit 1
fi

if [[ "$PASSWORD_PERMS" != "400" ]] && [[ "$PASSWORD_PERMS" != "444" ]]; then
  echo "ERROR: password file permissions are $PASSWORD_PERMS (expected 400 or 444)"
  exit 1
fi

# Verify content can be read
USERNAME_CONTENT=$(kubectl exec secure-app -n vault -- cat /etc/db-creds/username 2>/dev/null)
PASSWORD_CONTENT=$(kubectl exec secure-app -n vault -- cat /etc/db-creds/password 2>/dev/null)

if [[ "$USERNAME_CONTENT" != "dbadmin" ]]; then
  echo "ERROR: username content incorrect"
  exit 1
fi

if [[ "$PASSWORD_CONTENT" != "s3cur3P@ssw0rd" ]]; then
  echo "ERROR: password content incorrect"
  exit 1
fi

echo "SUCCESS: Secret mounted correctly with proper permissions"
exit 0
