# Reclaim Rescue

A PersistentVolume `archive-pv` contains important data. The PVC that was bound to it has been deleted, and the PV is now stuck in `Released` state.

Make the PV available for binding again and create a new PVC `archive-pvc` in namespace `reclaim-ns` that binds to it.

**Constraints:**
- The PV name must remain `archive-pv`.
- The new PVC must be named `archive-pvc` in namespace `reclaim-ns`.
- The PV's data must not be deleted.
