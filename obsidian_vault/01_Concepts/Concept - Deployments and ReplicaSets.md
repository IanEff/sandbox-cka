---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Chapter 11 - Deployments and ReplicaSets", "Deployments and ReplicaSets"]
---

# Concept - Deployments and ReplicaSets

- **ReplicaSet:** An API resource that ensures a specific number of identical pod instances are running.
- **Deployment:** A controller that manages ReplicaSets, providing declarative updates and rollbacks.

### Deploying ReplicaSets

**Command to generate YAML:**

```bash
kubectl create deployment app-cache --image memcached:latest --replicas=4 \
  --dry-run=client -o yaml
```

**Resulting YAML:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: app-cache
  name: app-cache
spec:
  replicas: 4
  selector:
    matchLabels:
      app: app-cache
  template:
    metadata:
      labels:
        app: app-cache
    spec:
      containers:
      - image: memcached:latest
        name: memcached
```

**Note:** Labels must match in three places:

1. `metadata.labels`
2. `spec.selector.matchLabels`
3. `spec.template.metadata.labels`

**Workload Primitives:**

- **Deployment:** For stateless apps.
- **StatefulSet:** For stateful apps (persistent identity/[[Topic - Storage|storage]]).
- **DaemonSet:** Ensures one instance per node.

### Updates and Rollbacks

- **Edit live deployment:**

  ```bash
  kubectl edit deployment app-cache
  ```

- **Update container image imperatively:**

  ```bash
  kubectl set image deployment web-server nginx=nginx:1.28.0
  ```

- **Rolling Updates Process:**
  1. Update logic (e.g., `set image`).
  2. Check status: `kubectl rollout status deployment app-cache`
  3. View history: `kubectl rollout history deployment app-cache`

- **Annotating changes (for history):**

  ```bash
  kubectl annotate deployment app-cache kubernetes.io/change-cause="memcached upgraded to 1.6.40"
  ```

- **Rolling back:**

  ```bash
  kubectl rollout undo deployment app-cache --to-revision=1
  ```

---
**Topics:** [[Topic - Architecture]], [[Topic - Storage]], [[Topic - Tooling]], [[Topic - Workloads]]
