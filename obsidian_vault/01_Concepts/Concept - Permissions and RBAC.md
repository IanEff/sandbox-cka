---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Permissions and RBAC", "Chapter 6 - Permissions and RBAC"]
---

# Concept - Permissions and RBAC

### Creating a new user

1. **Create an SSL key:**

   ```bash
   openssl genrsa -out <username>.key 2048
   ```

2. **Create a Certificate Signing Request (CSR):**

   ```bash
   openssl req -new -key <username>.key -out <username>.csr -subj "/CN=<username>/O=<groupname>"
   ```

3. **Register user in Kubernetes:**

   ```bash
   kubectl config set-credentials ian \
     --client-key=ian.key \
     --client-certificate=ian.csr \
     --embed-certs=true
   ```

   ```bash
   kubectl config get-users
   ```

### Creating a Service Account

- `kubectl create serviceaccount log-bot -n production`

### RBAC Concepts

`{subject, resource, verb}`

- **Subject:** User or Service Account.
- **Resource:** API resource type (e.g., pods, [[Concept - Services|services]]).
  - Check with: `kubectl api-resources -o wide`
- **apiGroup** The API group, chief
- **Verb:** Actions = {`create`, `get`, `list`, `watch`, `delete`, `update`, `patch`.}

An empty set of double quotes (“”) in the apiGroups field indicates the core API group.

### API Primitives for RBAC

`Account <--> RoleBinding <--> Role <--> Resource`

- **Role:** Defines the API resources and their permitted operations.
  - e.g., "Allow listing and deleting pods."
- **RoleBinding:** Binds a Role to a Subject.
  - e.g., "Bind the role that permits updating Services to the user Ian."

ClusterRols & roles

**Default Roles:** `cluster-admin`, `admin`, `edit`, `view`.

### Creating a Role

**Imperative:**

```bash
kubectl create role read-only --verb=list,get,watch \
  --resource=pods,deployments,services
```

**YAML:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: read-only
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["list", "get", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["list", "get", "watch"]
```

### Creating a RoleBinding

**Imperative:**

```bash
kubectl create rolebinding read-only-binding --role=read-only --user=ian
```

**YAML:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-only-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: read-only
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: ian
```

### Inspecting Roles

```bash
kubectl get roles
kubectl get rolebindings
kubectl describe role read-only
kubectl describe rolebinding read-only-binding
```

### Switching Contexts

After adding the user, approve them and add to a context:

```bash
kubectl certificate approve ian
kubectl config use-context ian
```

### Cluster-wide RBAC

Use `ClusterRole` and `ClusterRoleBinding` for cluster-level permissions.

### Aggregated ClusterRoles

Add a label to a `ClusterRole`, then create an aggregating `ClusterRole` that uses an `aggregationRule` with `clusterRoleSelectors`.

**Example:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: list-pods
  labels:
    rbac-pod-list: "true"
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pods-services-aggregation-rules
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac-pod-list: "true"
  - matchLabels:
      rbac-service-delete: "true"
rules: []
```

- **Note:** Naming is important; append `--aggregation-rules` or similar to the name.
- **Pods** have access to the `default` service account. This grants them:
  - `system:discovery`
  - `system:basic-user`
  - `system:service-account-lookup`

---
**Topics:** [[Topic - Networking]], [[Topic - Security]], [[Topic - Tooling]], [[Topic - Workloads]]
