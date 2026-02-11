# ETCD Snapshot

Perform a backup of the cluster's ETCD database.

## Requirements

1. Create a snapshot of the ETCD database.
2. Save the snapshot file to `/home/vagrant/etcd-snapshot.db`.
3. Ensure the file is created successfully.

## Tips

- ETCD runs as a static pod on the control plane.
- You will need to use `etcdctl`.
- Root certificates are located in `/etc/kubernetes/pki/etcd/`.
- Endpoint is likely `127.0.0.1:2379`.
