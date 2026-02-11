# Drill: Drain It

Your task is to safely drain the node named **`ubukubu-node-1`** for maintenance.
The node must be marked as unschedulable, and all pods (except DaemonSets) must be evicted.

**Requirements**:

1. `ubukubu-node-1` status must be `SchedulingDisabled`.
2. No pods from the `default` namespace (specifically `drain-test`) should be running on it.
3. Don't touch `ubukubu-control` or `ubukubu-node-2`.

**Tip**: Ignorance is bliss for some system pods.
