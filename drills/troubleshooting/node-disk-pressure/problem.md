# Node NotReady - Disk Pressure

One of the worker nodes in the cluster has gone NotReady due to disk pressure. Pods are being evicted and new pods can't be scheduled on it.

## Task

A node in the cluster is reporting `NotReady` status with the condition `DiskPressure=True`.

Your tasks:

1. Identify which node has the disk pressure issue
2. Clean up unnecessary resources consuming disk space (look for old container images, logs, or temporary files)
3. Verify the node returns to Ready status

The node should be schedulable again once the disk pressure is relieved.

**Hint**: You may need to SSH into the node or use `kubectl debug node/` to investigate and clean up disk space.
