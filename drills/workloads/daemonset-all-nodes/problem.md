# DaemonSet: Deploy on All Nodes Including Control Plane

Deploy a logging agent that must run on every node in the cluster, including the control plane.

Your tasks:

1. Create a DaemonSet named `log-collector` in namespace `monitoring`
2. Use image `busybox:1`
3. Command: `sh -c "while true; do echo 'Collecting logs from $(hostname)' >> /var/log/collector.log; sleep 60; done"`
4. Add labels: `app=log-collector` and `tier=infrastructure`
5. Request resources: 10m CPU and 20Mi memory
6. The DaemonSet must schedule pods on ALL nodes, including the control plane (which has a `node-role.kubernetes.io/control-plane` taint)

## Verification

- A pod should be running on each node (use `kubectl get pods -o wide` to verify)
- The control plane node should have a log-collector pod

**Hint**: You'll need to add a toleration for the control-plane taint.
