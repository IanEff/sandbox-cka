# Service Account Access

1. Create a Namespace named `infra`.
2. Create a ServiceAccount named `deployer` in the `infra` namespace.
3. Create a ClusterRoleBinding named `deployer-binding` that binds the `cluster-admin` ClusterRole to the ServiceAccount `deployer` in the `infra` namespace.
