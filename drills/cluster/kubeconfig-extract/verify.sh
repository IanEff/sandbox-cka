#!/bin/bash
# Verify

if [ ! -f "$HOME/admin.crt" ]; then
    echo "$HOME/admin.crt does not exist."
    exit 1
fi

# Check if it looks like a cert
head -n 1 "$HOME/admin.crt" | grep "BEGIN CERTIFICATE" >/dev/null
if [ $? -ne 0 ]; then
    echo "File does not start with BEGIN CERTIFICATE"
    exit 1
fi

# Validate against actual config
# Use kubectl/jsonpath to get real data
real_data=$(kubectl config view --raw -o jsonpath='{.users[?(@.name=="kubernetes-admin")].user.client-certificate-data}')

# If user not found, try finding first user
if [ -z "$real_data" ]; then
    real_data=$(kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}')
fi

# Compare md5
file_md5=$(cat ~/admin.crt | md5sum | awk '{print $1}')
config_md5=$(echo "$real_data" | base64 -d | md5sum | awk '{print $1}')

if [ "$file_md5" == "$config_md5" ]; then
    echo "Certificate matches."
    exit 0
else
    echo "Certificate MD5 mismatch."
    exit 1
fi
