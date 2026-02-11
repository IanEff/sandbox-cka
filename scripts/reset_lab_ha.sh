#!/bin/bash
set -e

# 🧨 Nuke and Pave: HA Lab Reset Script
# This script resets the 3 control plane nodes to a clean "Pre-Init" state.
# Use this to practice the 'kubeadm init' and 'kubeadm join' HA workflow repeatedly.

NODES=("ubukubu-control" "ubukubu-control-2" "ubukubu-control-3")

echo "🔄 Starting HA Lab Reset..."

for node in "${NODES[@]}"; do
    echo "--------------------------------------------------"
    echo "🧹 Cleaning $node..."
    
    # We use '|| true' to ensure the script continues even if a command complains
    vagrant ssh "$node" -c "
        # 1. Reset Kubernetes Cluster
        sudo kubeadm reset -f || true
        
        # 2. Clean CNI configurations (crucial for clean networking)
        sudo rm -rf /etc/cni/net.d
        
        # 3. Remove Kubeconfigs (so you don't use stale creds)
        sudo rm -rf /root/.kube
        sudo rm -rf /home/vagrant/.kube
        
        # 4. Ensure Etcd data is wiped
        sudo rm -rf /var/lib/etcd
        
        echo '✓ Reset complete for $node'
    "
done

echo "--------------------------------------------------"
echo "✅ HA Lab Reset Complete!"
echo ""
echo "Next Steps for CKA Practice:"
echo "1. vagrant ssh ubukubu-control"
echo "2. Run 'kubeadm init' with the Load Balancer endpoint (192.168.56.1:6443)"
echo "3. Join the other two nodes"
