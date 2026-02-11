# Storage: PVC Capacity Mismatch

A PersistentVolumeClaim named `restore-data` in the namespace `storage-drill` is stuck in a `Pending` state.

Investigate why it is not binding to the available PersistentVolume `manual-restore-pv`.

Fix the issue so that the PVC successfully binds. You can modify the PV or the PVC, but do not delete the PVC if possible (simulate that it holds important claim info, though in this case it's empty).
