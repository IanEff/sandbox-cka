# Pending PVC Troubleshooting

A Pod named `db-pod` in the `storage-issue` namespace is stuck in Pending state. It appears to be waiting for storage.

Requirements:

- Identify why the PVC is not binding (Hint: check events)
- Fix the issue so that `db-pod` can start running
- The fix should use the available `local-path` storage provisioner

Current state: exists, but pod is pending.
