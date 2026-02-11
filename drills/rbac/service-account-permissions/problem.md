# RBAC ServiceAccount Constraints

Create a limited-privilege ServiceAccount.

## Requirements

1. Work in namespace `rbac-drill`.
2. Create time a ServiceAccount named `limited-user`.
3. Create a Role named `deployment-manager` that allows:
   - **create**, **delete** on **deployments**.
   - **get**, **list** on **pods**.
   - **No other permissions**.
4. Create a RoleBinding named `limited-binding` binding the ServiceAccount to the Role.

## Verification

You can verify your work using:
`kubectl auth can-i create deployment --as=system:serviceaccount:rbac-drill:limited-user -n rbac-drill`
