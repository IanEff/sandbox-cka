#!/bin/bash
if [[ -s /var/lib/etcd-snapshot.db ]]; then
    exit 0
else
    echo "Snapshot file not found or empty"
    exit 1
fi
