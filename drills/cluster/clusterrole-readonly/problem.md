# ClusterRole for Read-Only Access

A monitoring team needs read-only access to view resources across all namespaces in the cluster, but should not be able to modify anything.

## Task

Create RBAC resources for a monitoring service account:

1. Create a ServiceAccount named `monitor-sa` in the `monitoring` namespace
2. Create a ClusterRole named `cluster-reader` that grants read-only permissions for:
   - pods, services, deployments (list, get, watch)
   - nodes (list, get)
   - namespaces (list, get)
3. Create a ClusterRoleBinding named `monitor-binding` that binds the `cluster-reader` ClusterRole to the `monitor-sa` ServiceAccount

Verify the RBAC is configured correctly and the service account has the intended permissions.
