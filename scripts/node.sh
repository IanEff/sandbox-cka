#!/bin/bash
set -e

echo "[NODE] Joining Cluster..."

if [ -f /vagrant/join.sh ]; then
    /bin/bash /vagrant/join.sh
else
    echo "ERROR: /vagrant/join.sh not found. Did the control plane initialize correctly?"
    exit 1
fi
