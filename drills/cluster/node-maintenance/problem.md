# Node Maintenance

## Problem

You need to perform maintenance on the worker node `ubukubu-node-1`.

1.  **Cordon** the node `ubukubu-node-1` to prevent new pods from being scheduled on it.
2.  **Drain** the node `ubukubu-node-1` to evict existing pods.
    - Ignore DaemonSets.
    - Delete local data if necessary.
    - Force eviction if necessary.

Ensure that the pod `maintenance-test-pod` which is currently running on `ubukubu-node-1` is successfully evicted.
