# ETCD Restore from Snapshot

A backup snapshot of the etcd cluster has been placed at `/opt/etcd-backup/snapshot.db`.

Your tasks:

1. Restore the etcd cluster from the snapshot to a new data directory at `/var/lib/etcd-restored`.
2. Update the etcd static pod manifest to use the new data directory.
3. Confirm etcd is running with the restored data.

## Information

- The etcd certificates are in `/etc/kubernetes/pki/etcd/`
- The etcd static pod manifest is at `/etc/kubernetes/manifests/etcd.yaml`
- The snapshot was taken with `etcdctl snapshot save`

**Warning**: This is a destructive operation. Make sure to backup the current etcd manifest before making changes.

*Hint*: Use `ETCDCTL_API=3 etcdctl snapshot restore ...` with appropriate flags. The `--data-dir` flag specifies where to restore.
