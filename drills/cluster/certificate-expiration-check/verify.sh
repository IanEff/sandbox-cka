#!/bin/bash

# Check if cert-status file exists
if [[ ! -f /tmp/cert-status.txt ]]; then
  echo "ERROR: File /tmp/cert-status.txt not found"
  echo "Run: kubeadm certs check-expiration > /tmp/cert-status.txt"
  exit 1
fi

# Verify file is not empty
if [[ ! -s /tmp/cert-status.txt ]]; then
  echo "ERROR: File /tmp/cert-status.txt is empty"
  exit 1
fi

# Check for expected kubeadm output content
if ! grep -q "CERTIFICATE" /tmp/cert-status.txt; then
  echo "ERROR: File does not contain expected kubeadm certificate output"
  echo "Expected output from: kubeadm certs check-expiration"
  exit 1
fi

# Verify it contains certificate names (apiserver, etcd, etc.)
if ! grep -E "(apiserver|etcd|front-proxy)" /tmp/cert-status.txt &>/dev/null; then
  echo "ERROR: File does not contain expected certificate information"
  exit 1
fi

# Check for expiration date information
if ! grep -E "[0-9]{4}" /tmp/cert-status.txt &>/dev/null; then
  echo "ERROR: File does not contain date information"
  exit 1
fi

# Verify this was run recently (file modified within last 5 minutes)
FILE_AGE=$(($(date +%s) - $(stat -c %Y /tmp/cert-status.txt 2>/dev/null || stat -f %m /tmp/cert-status.txt)))
if [[ $FILE_AGE -gt 300 ]]; then
  echo "WARNING: cert-status.txt is older than 5 minutes. Consider re-running the check."
fi

echo "SUCCESS: Certificate expiration status captured in /tmp/cert-status.txt"
echo ""
echo "Certificate summary:"
grep -A 20 "CERTIFICATE" /tmp/cert-status.txt | head -n 15 || true
exit 0
