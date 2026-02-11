# PVC Data Migration

The Pod `data-pod` in namespace `drill-storage` is currently using a PersistentVolumeClaim named `small-pvc` (10Mi).
The storage is insufficient. You need to migrate the data to a larger volume.

1. Create a new PVC named `large-pvc` in the same namespace with a capacity of `200Mi` and access mode `ReadWriteOnce`.
2. Migrate the data from `small-pvc` to `large-pvc`. Specifically, the file `/data/important.txt` must be preserved.
3. Update the `data-pod` to mount `large-pvc` at `/data` instead of `small-pvc`.

Note: You can delete and recreate the `data-pod` if necessary, but the final Pod must be named `data-pod`.
