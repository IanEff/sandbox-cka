# DaemonSet Control Plane Tolerance

Ensure a monitoring daemon runs on ALL nodes.

## Requirements

1. Work in namespace `ds-drill`.
2. Create a DaemonSet named `ds-all` using image `nginx:alpine`.
3. The DaemonSet must run a Pod on every node in the cluster, **including the control plane**.
4. The control plane node currently has a taint `node-role.kubernetes.io/control-plane:NoSchedule`. You must handle this in the DaemonSet spec (do not remove the taint from the node).

## Tips

- Use `tolerations`.
