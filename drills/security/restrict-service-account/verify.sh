#!/bin/bash
CAN_CREATE=$(kubectl auth can-i create pods --as=system:serviceaccount:web:deployer -n web)
CAN_LIST=$(kubectl auth can-i list pods --as=system:serviceaccount:web:deployer -n web)

if [[ "$CAN_CREATE" == "yes" ]] && [[ "$CAN_LIST" == "no" ]]; then
    exit 0
else
    echo "Permissions incorrect: Create=$CAN_CREATE, List=$CAN_LIST"
    exit 1
fi
