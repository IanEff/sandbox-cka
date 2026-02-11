# Static Mismatch

A PersistentVolume `manual-pv` has been provisioned for a specific task.
A PersistentVolumeClaim `manual-pvc` has been created to bind to it, but it remains in the `Pending` state.

**Tasks:**
1.  Investigate why `manual-pvc` is not binding to `manual-pv`.
2.  Fix the issue so that `manual-pvc` is `Bound` to `manual-pv`.
    *   *Note: You may need to recreate the PVC.*
