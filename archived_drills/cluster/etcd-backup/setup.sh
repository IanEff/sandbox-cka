#!/bin/bash
# Remove any existing snapshot to ensure fresh start
if [ -f /tmp/etcd-snapshot.db ]; then
    rm -f /tmp/etcd-snapshot.db
fi

echo "Environment ready. No special setup required."
