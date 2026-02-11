# ETCD Snapshot Backup

Perform a snapshot backup of the etcd cluster.

1. Save the snapshot to `/var/lib/etcd-snapshot.db`.
2. Use the certificates located in `/etc/kubernetes/pki/etcd/` (ca.crt, server.crt, server.key) if running from the control plane node.
3. The etcd endpoint is `https://127.0.0.1:2379`.

**Note**: You may need to install `etcd-client` or finding where `etcdctl` is hidden. On this system, `etcdctl` might be installed or you might need to use the `etcd` pod.
*Hint*: `kubectl -n kube-system exec -it etcd-<node> -- sh`... OR `ETCDCTL_API=3 etcdctl ...` on the host if available.
Assuming `etcdctl` is available on the control plane node (which you are on).
