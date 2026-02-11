#!/bin/bash
set -e

kubectl create ns dns-test --dry-run=client -o yaml | kubectl apply -f -

# Cleanup
kubectl delete deployment web service my-svc -n dns-test --ignore-not-found

# Create a simple service and deployment
kubectl create deployment web --image=nginx:alpine --replicas=1 -n dns-test
kubectl expose deployment web --port=80 --name=my-svc -n dns-test

# Wait for pod to be ready
kubectl wait --for=condition=ready pod -l app=web -n dns-test --timeout=60s

# Sabotage: Add a zone block to Corefile that breaks dns-test namespace resolution
# We'll patch the coredns configmap to add a bogus rewrite rule
kubectl get cm coredns -n kube-system -o yaml > /tmp/coredns-backup.yaml

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        rewrite stop name regex (.*)\.dns-test\.svc\.cluster\.local blackhole.invalid
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
EOF

# Restart coredns to pick up change
kubectl rollout restart deployment coredns -n kube-system
kubectl rollout status deployment coredns -n kube-system --timeout=60s

echo "Setup complete. DNS resolution for dns-test namespace is now broken."
