# Least Privilege RBAC

In namespace `rbac-4`, create a ServiceAccount named `pod-viewer`.

Create a **Role** named `pod-reader-role` and a **RoleBinding** named `pod-reader-binding` in the same namespace that allows this ServiceAccount to:

1. `list` and `get` Pods.
2. `get` (but not keep watching or listing) logs of Pods.
3. **NOT** delete, update, or create any resources.

Verify your work using `kubectl auth can-i`.
