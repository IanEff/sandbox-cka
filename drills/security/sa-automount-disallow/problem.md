# Drill: ServiceAccount Automount Disallow

## Scenario

Security audit requires that ServiceAccounts do not automatically mount API tokens into Pods unless explicitly required.

## Task

1. Create a ServiceAccount named `secure-sa` in the `default` namespace.
2. Configure it so that it does **not** automatically mount the Service Account token.
3. Create a Pod named `secure-pod` using image `nginx:alpine` that uses this ServiceAccount.

## Context

Default behavior is `automountServiceAccountToken: true`.


## Validation

Verify the ServiceAccount has automount disabled:
```bash
kubectl get sa secure-sa -o yaml | grep automount
# Should show: automountServiceAccountToken: false
```
Verify the Pod has no token volume mounted:
```bash
kubectl get pod secure-pod -o jsonpath='{.spec.containers[0].volumeMounts}'
# Should not include kube-api-access (token)
```
