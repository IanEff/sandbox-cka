# Run on All Nodes (DaemonSet)

Create a DaemonSet named `cluster-monitor` in namespace `workloads-8`.

* Image: `busybox`
* Command: `sleep 3600`
* **Requirement**: It must run a Pod on EVERY node in the cluster, including the control-plane node (which usually has taints).

Ensure you have the correct tolerations.
