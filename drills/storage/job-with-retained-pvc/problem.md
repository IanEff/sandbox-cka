# Storage: Backup Job with Retained Volume

A backup system needs to store data that persists even after the PVC is deleted.

Your tasks:

1. Create a StorageClass named `backup-storage`:
   - Provisioner: `rancher.io/local-path`
   - Volume binding mode: `WaitForFirstConsumer`
   - Reclaim policy: `Retain` (to prevent data loss if PVC is deleted)

2. Create a PersistentVolumeClaim named `backup-pvc` in namespace `backup-system`:
   - Request 100Mi of storage
   - Use the `backup-storage` StorageClass
   - Access mode: ReadWriteOnce

3. Create a Job named `backup-job` in namespace `backup-system`:
   - Image: `busybox:1`
   - Mount the PVC at `/backup`
   - Command: `sh -c "echo 'Backup completed at $(date)' > /backup/backup.log && cat /backup/backup.log"`
   - The Job should complete successfully

## Verification

- The Job completes successfully
- The PVC is Bound
- The StorageClass has reclaimPolicy: Retain
