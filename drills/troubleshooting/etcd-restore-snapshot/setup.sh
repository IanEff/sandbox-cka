#!/bin/bash
# Setup for ETCD Restore Drill
set -e

# Ensure backup directory exists
sudo mkdir -p /opt/etcd-backup

# Remove any previous restore directory
sudo rm -rf /var/lib/etcd-restored

# Create a fresh snapshot for the drill
sudo ETCDCTL_API=3 etcdctl snapshot save /opt/etcd-backup/snapshot.db \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    --endpoints=https://127.0.0.1:2379

# Verify snapshot was created
sudo ETCDCTL_API=3 etcdctl snapshot status /opt/etcd-backup/snapshot.db --write-out=table

echo "Setup complete. Snapshot saved at /opt/etcd-backup/snapshot.db"
echo "Restore it to /var/lib/etcd-restored and update the etcd manifest."
