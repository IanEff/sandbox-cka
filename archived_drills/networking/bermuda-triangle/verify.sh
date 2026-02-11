#!/bin/bash

kubectl exec -n airspace pilot -- curl -s --connect-timeout 2 control-tower.atlantic
if [ $? -eq 0 ]; then
    echo "SUCCESS: Contact established."
    exit 0
else
    echo "FAIL: Lost in the triangle."
    exit 1
fi
