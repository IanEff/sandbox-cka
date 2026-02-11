# Node Affinity Required

Create a Pod named `ssd-pod` using image `nginx` that **must** be scheduled on a node with the label `disk=ssd`.

1. Use `nodeAffinity` with `requiredDuringSchedulingIgnoredDuringExecution`.
2. Do not use `nodeSelector`.
3. The cluster currently has no nodes with this label, so the pod should remain Pending (or if you label a node, it should start, but we care about the spec).
