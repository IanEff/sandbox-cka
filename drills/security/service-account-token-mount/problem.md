# Drill: No Tokens Please

Create a Pod named `no-token` using image `nginx`.

**Restriction**: configuration must disable the automatic mounting of the ServiceAccount token.
Evidence: `kubectl describe pod no-token` should NOT show a volume mount for `/var/run/secrets/kubernetes.io/serviceaccount`.
