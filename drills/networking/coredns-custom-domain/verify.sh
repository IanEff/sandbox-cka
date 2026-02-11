#!/bin/bash
# Verify CoreDNS Custom Domain Drill
set -e

BACKUP_FILE="/home/vagrant/coredns-backup.yaml"

# Check backup exists
if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "FAIL: Backup file $BACKUP_FILE not found"
    exit 1
fi

# Verify backup is valid YAML with coredns content
if ! grep -q "coredns\|Corefile" "$BACKUP_FILE"; then
    echo "FAIL: Backup file does not appear to be CoreDNS ConfigMap"
    exit 1
fi
echo "PASS: Backup file exists"

# Check ConfigMap has custom domain
COREFILE=$(kubectl get configmap coredns -n kube-system -o jsonpath='{.data.Corefile}')
if ! echo "$COREFILE" | grep -q "internal.company"; then
    echo "FAIL: CoreDNS Corefile does not contain 'internal.company' domain"
    exit 1
fi
echo "PASS: Custom domain configured in Corefile"

# Wait for CoreDNS to be ready
kubectl rollout status deployment/coredns -n kube-system --timeout=60s

# Test DNS resolution - standard domain
echo "Testing standard domain resolution..."
STANDARD_RESULT=$(kubectl run dns-test-std --image=busybox:1 --restart=Never --rm -i --timeout=30s -- nslookup kubernetes.default.svc.cluster.local 2>&1 || echo "FAILED")

if echo "$STANDARD_RESULT" | grep -q "FAILED\|can't resolve\|server can't find"; then
    echo "FAIL: Standard domain resolution failed"
    echo "$STANDARD_RESULT"
    exit 1
fi
echo "PASS: Standard domain resolves"

# Test DNS resolution - custom domain
echo "Testing custom domain resolution..."
CUSTOM_RESULT=$(kubectl run dns-test-custom --image=busybox:1 --restart=Never --rm -i --timeout=30s -- nslookup kubernetes.default.svc.internal.company 2>&1 || echo "FAILED")

if echo "$CUSTOM_RESULT" | grep -q "FAILED\|can't resolve\|server can't find"; then
    echo "FAIL: Custom domain resolution failed"
    echo "$CUSTOM_RESULT"
    exit 1
fi
echo "PASS: Custom domain resolves"

echo "SUCCESS: CoreDNS custom domain configured correctly"
