# Fix Pending Pod (Node Affinity)

A critical workload is stuck in Pending state.

## Requirements

1. Check the Deployment `important-work` in namespace `scheduling-drill`.
2. Determine why the Pods are pending.
3. The workload requires a node with the label `tier=gold`.
4. Fix the issue by applying the required label to the worker node (`ubukubu-worker` or similar - check available nodes).
5. **Do not** modify the Deployment or Pod spec.
