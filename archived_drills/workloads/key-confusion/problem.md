# Secret Injection

A deployment `api-server` in namespace `secrets-ns` is failing to start. The application requires database credentials to be available as environment variables.

Fix the issue so all pods become Ready.

**Constraints:**
- The secret must be named `db-credentials`.
- The deployment name must remain `api-server`.
- Do not modify the deployment's environment variable names.
