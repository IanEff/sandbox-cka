# Manual HostPath PV

1. Create a PersistentVolume named `manual-pv`:
   - Capacity: `1Gi`
   - AccessMode: `ReadWriteOnce`
   - HostPath: `/mnt/data`
   - ReclaimPolicy: `Retain`
   - StorageClass: `manual`

2. Create a PersistentVolumeClaim named `manual-pvc`:
   - Request: `1Gi`
   - StorageClass: `manual`
   - **Must** bind to `manual-pv`.
   
   *Tip: You might need to clean up any automatic binding interference or specific `volumeName` binding.*
