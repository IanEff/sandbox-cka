#!/bin/bash
SNAPSHOT_FILE="/tmp/etcd-snapshot.db"

if [ ! -f "$SNAPSHOT_FILE" ]; then
    echo "FAIL: Snapshot file $SNAPSHOT_FILE does not exist."
    exit 1
fi

# Verify it is a valid snapshot using etcdctl (provided by etcd-client)
# Note: we don't strictly need to talk to the cluster to check the snapshot file integrity,
# but using the implicit v3 API is required.
export ETCDCTL_API=3 

if etcdctl snapshot status "$SNAPSHOT_FILE" > /dev/null 2>&1; then
    echo "SUCCESS: Snapshot verified."
    exit 0
else
    echo "FAIL: File exists but is not a valid etcd snapshot."
    exit 1
fi
