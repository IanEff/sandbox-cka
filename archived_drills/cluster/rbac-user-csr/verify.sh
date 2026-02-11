#!/bin/bash

# Check if Role exists
if ! kubectl -n development get role pod-reader >/dev/null 2>&1; then
    echo "Role 'pod-reader' not found in 'development'."
    exit 1
fi

# Check if RoleBinding exists
if ! kubectl -n development get rolebinding jane-pod-reader >/dev/null 2>&1; then
    echo "RoleBinding 'jane-pod-reader' not found in 'development'."
    exit 1
fi

# Check if CSR was approved (we can't easily check if they did it, but we can check if they have the cert and context)
# We will try to use the user 'jane' to list pods.
# Since we don't have their key/cert in this script easily unless they saved it to a specific location,
# we will check the RBAC rules using 'kubectl auth can-i'.

# Check permissions for user 'jane'
CAN_LIST=$(kubectl auth can-i list pods -n development --as jane)
CAN_DELETE=$(kubectl auth can-i delete pods -n development --as jane)

if [ "$CAN_LIST" == "yes" ] && [ "$CAN_DELETE" == "no" ]; then
    echo "User 'jane' has correct permissions."
    exit 0
else
    echo "User 'jane' permissions incorrect. List: $CAN_LIST, Delete: $CAN_DELETE"
    exit 1
fi
