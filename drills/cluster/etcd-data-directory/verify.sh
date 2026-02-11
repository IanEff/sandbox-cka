#!/bin/bash
if [[ ! -f /home/vagrant/etcd-data.txt ]]; then echo "File missing"; exit 1; fi
CONTENT=$(cat /home/vagrant/etcd-data.txt)

# Normalize: remove trailing slash and trim whitespace
CONTENT=$(echo "$CONTENT" | sed 's:/*$::')

# Usually /var/lib/etcd
if [[ "$CONTENT" != "/var/lib/etcd" ]]; then echo "Wrong path: $CONTENT"; exit 1; fi
