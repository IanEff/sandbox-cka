#!/bin/bash

NS="drill-rbac"
SA="pod-viewer"

# Check exists
if ! kubectl get sa $SA -n $NS >/dev/null 2>&1; then
    echo "ServiceAccount missing"
    exit 1
fi

# Check Permissions
CAN_LIST=$(kubectl auth can-i list pods --as=system:serviceaccount:$NS:$SA -n $NS)
CAN_GET=$(kubectl auth can-i get pods --as=system:serviceaccount:$NS:$SA -n $NS)
CAN_DELETE=$(kubectl auth can-i delete pods --as=system:serviceaccount:$NS:$SA -n $NS)
CAN_SECRETS=$(kubectl auth can-i list secrets --as=system:serviceaccount:$NS:$SA -n $NS)

if [ "$CAN_LIST" = "yes" ] && [ "$CAN_GET" = "yes" ] && [ "$CAN_DELETE" = "no" ] && [ "$CAN_SECRETS" = "no" ]; then
    echo "Permissions correct."
    exit 0
else
    echo "Permissions incorrect: LIST=$CAN_LIST (exp yes), GET=$CAN_GET (exp yes), DELETE=$CAN_DELETE (exp no), SECRETS=$CAN_SECRETS (exp no)"
    exit 1
fi
