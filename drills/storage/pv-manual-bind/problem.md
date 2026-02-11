# Manual PV Binding

You need to schedule a Pod that requires specific storage properties.

## Requirements

1. Work in namespace `manual-bind`.
2. Create a PersistentVolume named `manual-disk`.
   - Capacity: `100Mi`
   - AccessMode: `ReadWriteOnce`
   - HostPath: `/opt/manual-disk`
   - StorageClassName: `manual`
3. Create a PersistentVolumeClaim named `manual-pvc`.
   - Request: `50Mi` (Wait, request usually matches or is less, but for binding we often match) -> Request `50Mi` is fine.
   - StorageClassName: `manual`
   - **Constraint**: It must bind *specifically* to `manual-disk` regardless of other PVs. (Hint: `volumeName`).
4. Update the existing pending Pod `data-writer` to use this PVC mounted at `/data`.
