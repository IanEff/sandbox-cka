# RBAC Lockdown

A ServiceAccount `deploy-bot` in namespace `rbac-ns` needs to create, list, and delete Deployments in the `rbac-ns` namespace only.

Currently, `deploy-bot` cannot perform these actions.

Create the necessary RBAC resources to grant these permissions.

**Constraints:**
- Use a Role and RoleBinding (not ClusterRole/ClusterRoleBinding).
- Permissions must be scoped to namespace `rbac-ns` only.
- The ServiceAccount name must remain `deploy-bot`.
