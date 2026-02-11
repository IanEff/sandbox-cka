# Node Affinity & Scheduling

Create a Deployment named `ssd-deployment` in namespace `hardware-ops`.

- Image: `nginx:alpine`
- Replicas: 1
- **Constraint**: The Pods must *only* be scheduled on nodes that have the label `disktype=ssd`. (Use `requiredDuringSchedulingIgnoredDuringExecution`).

Currently, the Pod is likely in a `Pending` state.
Fix the situation by adding the required label `disktype=ssd` to the control-plane node (or any available worker node).
Ensure the Pod enters the `Running` state.
