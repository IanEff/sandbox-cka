# Secret File Permissions

A pod named `secure-app` in the `vault` namespace needs to access database credentials from a secret, but the application is failing to read the credentials file.

The secret `db-credentials` contains:

- `username`: database username
- `password`: database password

Requirements:

- The pod must mount the secret as files in `/etc/db-creds/`
- The mounted secret files must have restrictive permissions (0400)
- The application expects both `username` and `password` files to exist
- Verify the pod can successfully read the credentials

Current state: The pod exists but cannot access the credential files properly.
