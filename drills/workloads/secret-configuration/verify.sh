#!/bin/bash
set -e

# Check pod exists and is running
if ! kubectl get pod api-server -n apps &>/dev/null; then
    echo "❌ Pod 'api-server' not found in apps namespace"
    exit 1
fi

# Wait for pod to be ready
if ! kubectl wait --for=condition=ready --timeout=30s pod/api-server -n apps &>/dev/null; then
    echo "❌ Pod 'api-server' is not ready"
    exit 1
fi

# Check environment variables
db_user=$(kubectl exec api-server -n apps -- sh -c 'echo $DB_USER' 2>/dev/null || echo "")
db_pass=$(kubectl exec api-server -n apps -- sh -c 'echo $DB_PASS' 2>/dev/null || echo "")

if [ "$db_user" != "admin" ]; then
    echo "❌ DB_USER environment variable not set correctly (found: '$db_user')"
    exit 1
fi

if [ "$db_pass" != "secret123" ]; then
    echo "❌ DB_PASS environment variable not set correctly"
    exit 1
fi

# Check mounted file
if ! timeout 5 kubectl exec api-server -n apps -- test -f /etc/config/database.conf &>/dev/null; then
    echo "❌ File /etc/config/database.conf not found in pod"
    exit 1
fi

db_content=$(kubectl exec api-server -n apps -- cat /etc/config/database.conf 2>/dev/null || echo "")
if [ "$db_content" != "myapp" ]; then
    echo "❌ File /etc/config/database.conf does not contain expected value"
    exit 1
fi

echo "✅ Pod configured correctly with secrets as env vars and volume mount"
exit 0
