#!/bin/bash
rm -f /var/lib/etcd-snapshot.db
# Ensure user has permissions or warn them? Drill runner runs as root? Usually user on control plane is vagrant/ubuntu, might need sudo.
# We'll assume they have sudo.
