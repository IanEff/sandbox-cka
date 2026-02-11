# RBAC Pod Creator

## Scenario

A new developer needs access to namespace `dev-team`. They should be able to view and create Pods, but **NOT** delete them.

## Requirements

- **Namespace**: `dev-team`
- **ServiceAccount**: `developer`
- **Role**: `pod-manager`
  - Resources: `pods`
  - Verbs: `create`, `list`, `get` (Ensure `delete` is NOT included)
- **RoleBinding**: `dev-binding` linking SA `developer` to Role `pod-manager`.

## Verification

The drill will use `kubectl auth can-i --as` to verify permissions.
