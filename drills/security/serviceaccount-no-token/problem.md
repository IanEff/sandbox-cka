# ServiceAccount Token Mount Control

## Objective
Create a ServiceAccount that does **not** automatically mount its token, and a Pod that uses it.

## Instructions
1.  Create a Namespace named `security`.
2.  Create a ServiceAccount named `no-token-sa` in the `security` namespace.
    *   Ensure that this ServiceAccount does **NOT** automatically mount its API token to Pods.
3.  Create a Pod named `secure-pod` in the `security` namespace.
    *   Use the image `nginx:alpine`.
    *   Run as the `no-token-sa` ServiceAccount.

## Verification
The Pod `secure-pod` should be running and should **not** have a volume mounted at `/var/run/secrets/kubernetes.io/serviceaccount`.
