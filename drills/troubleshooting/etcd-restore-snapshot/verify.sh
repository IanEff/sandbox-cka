#!/bin/bash
# Verify ETCD Restore Drill
set -e

#!/bin/bash
# Verify ETCD Restore Drill
set -e

# Check that the restored data directory exists
# Use sudo because /var/lib/etcd* directories are often root-owned/restrictive
if ! sudo test -d /var/lib/etcd-restored; then
    echo "FAIL: Restored data directory /var/lib/etcd-restored does not exist"
    exit 1
fi

# Check that the etcd manifest points to the new data directory
# Use sudo because /etc/kubernetes/manifests/etcd.yaml is root-readable only
if ! sudo grep -q "/var/lib/etcd-restored" /etc/kubernetes/manifests/etcd.yaml; then
    echo "FAIL: etcd manifest does not reference /var/lib/etcd-restored"
    exit 1
fi

# Wait for etcd pod to be running (with timeout)
# kubectl works fine as the 'vagrant' user
echo "Waiting for etcd to be running..."
timeout 60 bash -c 'until kubectl get pods -n kube-system -l component=etcd --no-headers 2>/dev/null | grep -q Running; do sleep 2; done'

# Verify etcd is healthy
# Use sudo so etcdctl can read the PKI keys in /etc/kubernetes/pki/etcd/
sudo ETCDCTL_API=3 etcdctl endpoint health \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    --endpoints=https://127.0.0.1:2379

if [[ $? -eq 0 ]]; then
    echo "SUCCESS: etcd restored and healthy"
    exit 0
else
    echo "FAIL: etcd is not healthy"
    exit 1
fi
