#!/bin/bash
# Setup for operator-repair drill

# Cleanup
kubectl delete pod dummy-operator --force --grace-period=0 2>/dev/null || true
kubectl delete clusterrole dummy-operator-role 2>/dev/null || true
kubectl delete clusterrolebinding dummy-operator-binding 2>/dev/null || true
kubectl delete sa dummy-operator 2>/dev/null || true

# Create SA
kubectl create sa dummy-operator

# Create defective ClusterRole (missing configmaps)
kubectl create clusterrole dummy-operator-role --verb=list,watch --resource=pods

# Bind it
kubectl create clusterrolebinding dummy-operator-binding --clusterrole=dummy-operator-role --serviceaccount=default:dummy-operator

# Create Operator Pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: dummy-operator
spec:
  serviceAccountName: dummy-operator
  containers:
  - name: operator
    image: bitnami/kubectl:latest
    command:
    - /bin/bash
    - -c
    - |
      while true; do
        if kubectl get configmaps > /dev/null 2>&1; then
          echo "Watching ConfigMaps..."
          sleep 10
        else
          echo "Error: Cannot list ConfigMaps"
          exit 1
        fi
      done
  restartPolicy: Always
EOF
