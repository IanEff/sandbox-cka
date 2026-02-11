# Service Account Permissions

## Instructions

Create a ServiceAccount named `monitor` in the `default` namespace.

Grant this ServiceAccount permission to `list` `pods` in the `default` namespace.

Finally, create a Pod named `monitor-pod` in the `default` namespace that uses this ServiceAccount.

## Verification

The command `kubectl auth can-i list pods --as=system:serviceaccount:default:monitor` should return `yes`.
The Pod `monitor-pod` should be running and using the `monitor` ServiceAccount.
