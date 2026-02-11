# Configure Application with Secrets

An application needs database credentials provided securely. The pod is failing because the environment variables aren't set correctly.

## Task

A Secret named `db-credentials` exists in the `apps` namespace with keys:

- `username`
- `password`
- `database`

A Pod named `api-server` exists but is not configured to use these secrets. Update the pod so that:

1. The `username` and `password` are exposed as environment variables `DB_USER` and `DB_PASS`
2. The `database` value is mounted as a file at `/etc/config/database.conf`

Recreate the pod if necessary. Verify the configuration is correctly applied.
