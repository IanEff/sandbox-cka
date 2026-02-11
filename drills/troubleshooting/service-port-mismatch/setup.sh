#!/bin/bash
# troubleshooting/service-port-mismatch/setup.sh

# Create Deployment (container port 80)
kubectl create deployment port-test --image=nginx:alpine --replicas=1 --dry-run=client -o yaml | kubectl apply -f -

# Create Service manually (pointing to port 8080)
kubectl create service clusterip port-test-svc --tcp=80:8080
# The pod has label app=port-test, create service usually picks that up if we use expose, 
# but create service clusterip does not auto-select. We need to patch the selector.
# Waiting for the previous command to see what selector it created (it usually creates none for create service clusterip?)
# Actually 'kubectl create service' requires manual selector specification or manual endpoint creation usually.
# Let's do it declaratively to be sure.

kubectl delete service port-test-svc 2>/dev/null || true

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: port-test-svc
spec:
  selector:
    app: port-test
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
EOF
