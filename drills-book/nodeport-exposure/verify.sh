#!/bin/bash
DIR="/opt/course/overlay5"
NS="external-apps"

[ -f "$DIR/nodeport.txt" ] || { echo "Missing nodeport.txt"; exit 1; }

TYPE=$(kubectl get svc api-gateway-svc -n $NS -o jsonpath='{.spec.type}')
if [ "$TYPE" != "NodePort" ]; then echo "Service type is $TYPE, expected NodePort"; exit 1; fi

kubectl get deploy api-gateway -n $NS > /dev/null 2>&1 || { echo "Deploy missing"; exit 1; }

exit 0
