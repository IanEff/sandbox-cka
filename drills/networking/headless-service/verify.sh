#!/bin/bash
set -e

# Check service exists
if ! kubectl get service database-headless -n data &>/dev/null; then
    echo "❌ Service 'database-headless' not found in data namespace"
    exit 1
fi

# Check service is headless (clusterIP: None)
cluster_ip=$(kubectl get service database-headless -n data -o jsonpath='{.spec.clusterIP}')
if [ "$cluster_ip" != "None" ]; then
    echo "❌ Service is not headless (clusterIP: '$cluster_ip', expected 'None')"
    exit 1
fi

# Check selector
selector_app=$(kubectl get service database-headless -n data -o jsonpath='{.spec.selector.app}')
if [ "$selector_app" != "database" ]; then
    echo "❌ Service selector app is '$selector_app', expected 'database'"
    exit 1
fi

# Check port
port=$(kubectl get service database-headless -n data -o jsonpath='{.spec.ports[0].port}')
if [ "$port" != "3306" ]; then
    echo "❌ Service port is '$port', expected '3306'"
    exit 1
fi

target_port=$(kubectl get service database-headless -n data -o jsonpath='{.spec.ports[0].targetPort}')
if [ "$target_port" != "3306" ]; then
    echo "❌ Service targetPort is '$target_port', expected '3306'"
    exit 1
fi

# Create a test pod to verify DNS resolution
kubectl run dns-test --image=busybox:1.36 --rm -i -n data --restart=Never --command -- sh -c "nslookup database-0.database-headless.data.svc.cluster.local" &>/dev/null
dns_test=$?

if [ $dns_test -ne 0 ]; then
    echo "❌ DNS resolution test failed for individual pod"
    kubectl delete pod dns-test -n data --ignore-not-found=true &>/dev/null
    exit 1
fi

echo "✅ Headless service configured correctly with proper DNS resolution"
exit 0
