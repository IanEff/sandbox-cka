# Restricted ServiceAccount

Create a ServiceAccount named `pod-viewer` in namespace `restrict-ns`.
Create a Role `pod-view-role` and RoleBinding `pod-view-binding` in the same namespace.
The ServiceAccount should *only* be able to `list` and `get` Pods in `restrict-ns`.
It should **not** be able to access Secrets or Services.
