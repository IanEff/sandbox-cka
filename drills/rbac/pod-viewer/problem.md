# RBAC Pod Viewer

In the namespace `drill-rbac`:
1. Create a ServiceAccount named `pod-viewer`.
2. Create a Role named `pod-view-role` and a RoleBinding named `pod-view-bind`.
3. The ServiceAccount should have permissions to `get` and `list` Pods in the namespace.
4. It should **not** have permissions to view other resources or modify Pods.
