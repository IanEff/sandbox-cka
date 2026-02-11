# Storage: PV, PVC, and Pod

Create a solution in namespace `sci-storage`:

1. Create a `PersistentVolume` named `sci-pv`.
   - Capacity: `1Gi`
   - Access Mode: `ReadWriteMany`
   - Storage Class: `manual`
   - Host Path: `/mnt/data/sci`

2. Create a `PersistentVolumeClaim` named `sci-pvc` in namespace `sci-storage`.
   - Request: `500Mi`
   - Access Mode: `ReadWriteMany`
   - Storage Class: `manual`
   - Ensure it binds to `sci-pv`.

3. Create a Pod named `data-processor`.
   - Image: `busybox`
   - Command: `sh -c "echo 'Processing' > /data/status; sleep 3600"`
   - Volume: Mount the `sci-pvc` at `/data`.
