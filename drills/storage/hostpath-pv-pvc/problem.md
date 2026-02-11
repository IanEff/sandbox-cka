# Manual PersistentVolume Wiring

Create a PersistentVolume and a PersistentVolumeClaim to explicitly wire them together.

1. Create a `PersistentVolume` named `manual-pv-3`.
    * Capacity: `500Mi`
    * Access Mode: `ReadWriteOnce`
    * Storage Class: `manual`
    * Host Path: `/mnt/data-3`
2. Create a `PersistentVolumeClaim` named `manual-pvc-3` in namespace `storage-3`.
    * Request: `200Mi`
    * Access Mode: `ReadWriteOnce`
    * Storage Class: `manual`
    * **Crucial**: Inspect the PV and ensure the PVC binds to `manual-pv-3` specifically.
3. Create a Pod named `data-consumer` in namespace `storage-3`.
    * Image: `nginx`
    * Mount the PVC to `/usr/share/nginx/html`.
