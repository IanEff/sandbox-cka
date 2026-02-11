# StatefulSet with Local Storage

Deploy a stateful application that uses the cluster's local path provisioner for persistent storage.

Requirements:

- Create a StatefulSet named `kv-store` in the `data` namespace
- Use image `redis:alpine`
- Run 2 replicas
- Configure a `volumeClaimTemplate` named `data`
- The Template MUST use `storageClassName: local-path`
- Request 100Mi of storage
- Verify that PVCs are created and bound (e.g., `data-kv-store-0`)

Current state: Namespace `data` does not exist.
