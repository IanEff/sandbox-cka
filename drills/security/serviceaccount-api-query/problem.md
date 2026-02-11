# ServiceAccount: Query Kubernetes API

A ServiceAccount named `api-explorer` exists in namespace `project-api`. Create a Pod that uses this ServiceAccount to query the Kubernetes API.

Your tasks:

1. Create a Pod named `api-query` in namespace `project-api` using image `curlimages/curl:latest`
2. The Pod should use ServiceAccount `api-explorer`
3. The Pod should run a sleep command to stay alive (e.g., `sleep 3600`)
4. Exec into the Pod and use `curl` to query all Secrets in namespace `project-api` from the Kubernetes API
5. Write the JSON result to `/home/vagrant/api-secrets.json`

## Information

- The ServiceAccount already has appropriate RBAC permissions
- The Kubernetes API is available at `https://kubernetes.default.svc`
- The ServiceAccount token is mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token`
- The CA certificate is at `/var/run/secrets/kubernetes.io/serviceaccount/ca.crt`

**Hint**: Use `curl --cacert <ca-file> -H "Authorization: Bearer $(cat <token-file>)" https://kubernetes.default.svc/api/v1/namespaces/project-api/secrets`
