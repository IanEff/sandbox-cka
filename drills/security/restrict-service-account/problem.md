# Restrict Service Account

1. Create a namespace named `web`.
2. Create a ServiceAccount named `deployer` in namespace `web`.
3. Create a Role named `pod-creator` in namespace `web` that allows:
   - verbs: `create`
   - resources: `pods`
4. Create a RoleBinding named `deployer-binding` in namespace `web` binding the Role to the ServiceAccount.

Ensure the ServiceAccount can create pods but cannot list them.
