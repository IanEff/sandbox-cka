# Resize Persistent Volume

The PersistentVolumeClaim named `resize-me-pvc` in the `default` namespace is running out of space.

1. Resize the PVC to `100Mi`.
2. Ensure the change is accepted.

> Note: The StorageClass `local-path` supports volume expansion.
