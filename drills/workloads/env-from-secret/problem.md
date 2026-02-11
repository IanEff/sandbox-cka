# EnvFrom Secret

**Drill Goal:** Inject all key-value pairs from a Secret as environment variables.

## Problem

1.  Create a Secret named `app-config` in the `default` namespace with the following key-values:
    *   `DB_HOST=sql.example.com`
    *   `DB_PORT=5432`
2.  Create a Pod named `env-pod` (image `nginx:alpine`).
3.  Configure the Pod to expose **all** keys from the `app-config` Secret as environment variables (do not map them individually).

## Validation

Verify that `env-pod` has environment variables `DB_HOST` and `DB_PORT` set.
