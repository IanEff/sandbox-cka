# Cluster Architecture: Node Maintenance

We need to perform kernel upgrades on `ubukubu-node-1`.

1. Safely drain `ubukubu-node-1` to evict all standard workloads.
2. Ensure the node is marked as unschedulable (`SchedulingDisabled`).
3. You do not need to delete DaemonSets (use `--ignore-daemonsets`).
