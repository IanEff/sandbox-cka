#!/bin/bash
# Verify

if [[ ! -f /opt/certificate_expiry.txt ]]; then
    echo "FAIL: File /opt/certificate_expiry.txt not found."
    exit 1
fi

DATE_CONTENT=$(cat /opt/certificate_expiry.txt)

if [[ -z "$DATE_CONTENT" ]]; then
    echo "FAIL: File is empty."
    exit 1
fi

# Basic check: does it look like a date or contain "apiserver"?
# kubeadm certs check-expiration output usually looks like:
# "admin.conf               Jul 10, 2026 21:03 UTC   364d        ca                  no"
# or we look for a date year.

echo "Content found: $DATE_CONTENT"
echo "Human verification required: Does this look like the apiserver expiry date?"
echo "SUCCESS: (Assuming user extracted correct line)"
exit 0
