# Taint and Toleration Scheduling

1. Identify a worker node (not the control plane) and add a taint: `maintenance=true:NoSchedule`.
2. Create a Pod named `sys-admin-pod` in namespace `scheduling-7` using image `nginx`.
3. Configure this Pod so it creates successfully and is running on the tainted node.
4. Ensure it also uses `run=maintenance` as a label, just in case we need to track it later.
5. Use `nodeAffinity` to **ensure** it schedules ONLY on the node with label `maintenance=true` (You need to add this label yourself to the same node).

Summary:

* Node: Label `maintenance=true`, Taint `maintenance=true:NoSchedule`
* Pod: Tolerates taint, Affinity to label.
