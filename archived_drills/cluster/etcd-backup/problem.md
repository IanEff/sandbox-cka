# Etcd Snapshot

You must take a snapshot of the cluster's etcd database.

**Tasks:**
1. Create a snapshot of the etcd database using `etcdctl` (or the `etcd-client` provided).
2. Save the snapshot to `/tmp/etcd-snapshot.db`.

**Notes:**
- You are on the control plane node.
- The certificates for etcd are usually located in `/etc/kubernetes/pki/etcd`.
- The etcd endpoint is usually `https://127.0.0.1:2379`.
