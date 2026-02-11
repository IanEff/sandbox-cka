# Node Taint & Toleration

The Deployment `monitor-agent` in `drill-scheduling` must run on the control plane node `ubukubu-control`.
However, the Pods are currently Pending.

1. Analyze why the Pods are Pending.
2. Modify the Deployment `monitor-agent` to allow it to be scheduled on `ubukubu-control`.
3. Do **not** remove the Taint from the node.
4. Do **not** remove the NodeAffinity from the Deployment.
