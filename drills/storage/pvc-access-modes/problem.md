# PVC Access Modes

A developer needs to create a Persistent Volume Claim on this cluster. The available CSI storage backend is `local-path`, which only supports single-node attachment.

## Task

Create a PVC named `shared-data` in the `default` namespace that:

- Requests 2Gi of storage
- Uses the `local-path` storage class
- Uses an access mode compatible with `local-path`
- Should be successfully bound

Verify that the PVC is bound and has the correct access mode configured.
