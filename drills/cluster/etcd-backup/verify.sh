#!/bin/bash

FILE="/home/vagrant/etcd-snapshot.db"

if [ ! -f "$FILE" ]; then
    echo "Snapshot file not found at $FILE"
    exit 1
fi

# Size check
SIZE=$(stat -c%s "$FILE")
if [ "$SIZE" -lt 1000 ]; then
    echo "File too small ($SIZE bytes), likely empty."
    exit 1
fi

echo "Snapshot exists and has data ($SIZE bytes)."

# Optional deep check if etcdctl exists
if command -v etcdctl &> /dev/null; then
  echo "Verifying snapshot integrity..."
  if sudo ETCDCTL_API=3 etcdctl snapshot status "$FILE" > /dev/null 2>&1; then
      echo "Snapshot Valid."
      exit 0
  else
      echo "Snapshot Invalid."
      exit 1
  fi
else
  echo "etcdctl not found, strictly checking file size only. Passed."
  exit 0
fi
