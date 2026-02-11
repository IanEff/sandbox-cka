# Kubeadm Node Maintenance

A critical security patch requires draining and cordoning node `ubukubu-node-1` for maintenance.

A deployment `critical-app` is running in namespace `maintenance-test` with 3 replicas.

**Your Task:**
1. Safely drain `ubukubu-node-1` ensuring the `critical-app` pods are rescheduled.
2. Simulate maintenance completion by uncordoning the node.

**Constraints:**
- The `critical-app` deployment must maintain at least 2 available replicas throughout.
- All pods must be rescheduled before uncordoning.
- Node must be schedulable when verification runs.
