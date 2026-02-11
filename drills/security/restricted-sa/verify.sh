#!/bin/bash
NS="restrict-ns"
SA="pod-viewer"

# Check if SA exists
kubectl get sa $SA -n $NS > /dev/null 2>&1 || exit 1

# Check permissions
# Should be allowed
kubectl auth can-i list pods --as=system:serviceaccount:$NS:$SA -n $NS | grep -q "yes" || exit 1
kubectl auth can-i get pods --as=system:serviceaccount:$NS:$SA -n $NS | grep -q "yes" || exit 1

# Should be denied
kubectl auth can-i get secrets --as=system:serviceaccount:$NS:$SA -n $NS | grep -q "no" || exit 1
kubectl auth can-i list services --as=system:serviceaccount:$NS:$SA -n $NS | grep -q "no" || exit 1

echo "Verification success"
exit 0
