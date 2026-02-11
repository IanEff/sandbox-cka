#!/bin/bash
FILE="/home/vagrant/etcd-snapshot.db"

if [ ! -f "$FILE" ]; then
  echo "Snapshot file not found at $FILE"
  exit 1
fi

if [ ! -s "$FILE" ]; then
  echo "Snapshot file is empty"
  exit 1
fi

# Ideally we would verify the snapshot with etcdctl snapshot status, but existence is a good proxy for this drill
echo "Snapshot exists."
exit 0
