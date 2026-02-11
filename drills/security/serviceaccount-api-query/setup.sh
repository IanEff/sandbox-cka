#!/bin/bash
# Setup for ServiceAccount API Query Drill
set -e

# Cleanup
kubectl delete ns project-api --ignore-not-found=true --wait=true
rm -f /home/vagrant/api-secrets.json

# Create namespace
kubectl create ns project-api

# Create ServiceAccount
kubectl create sa api-explorer -n project-api

# Create Role that allows reading secrets
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
  namespace: project-api
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
EOF

# Bind the role to the ServiceAccount
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: api-explorer-secrets
  namespace: project-api
subjects:
- kind: ServiceAccount
  name: api-explorer
  namespace: project-api
roleRef:
  kind: Role
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
EOF

# Create some secrets to query
kubectl create secret generic db-password --from-literal=password=supersecret -n project-api
kubectl create secret generic api-key --from-literal=key=abc123 -n project-api

echo "Setup complete."
echo "Create Pod 'api-query' using ServiceAccount 'api-explorer'"
echo "Query secrets via API and save to /home/vagrant/api-secrets.json"
