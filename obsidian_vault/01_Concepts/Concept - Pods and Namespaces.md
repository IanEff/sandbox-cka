---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Pods and Namespaces", "Chapter 9 - Pods and Namespaces"]
---

# Concept - Pods and Namespaces

### The `run` command

Imperative way to create a pod:

```bash
kubectl run hazelcast --image=hazelcast/hazelcast:latest \
  --port=5701 \
  --env="DNS_DOMAIN=cluster" \
  --labels="app=hazelcast,env=prod"
```

- `--rm true`: Deletes pod after the container finishes.
- `--env`: Set environment variables.
- `--labels`: Set labels.

**Declarative way (YAML):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hazelcast
  labels:
    app: hazelcast
    env: prod
spec:
  containers:
  - name: hazelcast
    image: hazelcast/hazelcast:5.1.7
    env:
    - name: DNS_DOMAIN
      value: cluster
    ports:
    - containerPort: 5701
```

### Navigating Pods

```bash
kubectl get pods hazelcast       # By pod name
kubectl get pods -l app=hazelcast # By label
```

### Pod Lifecycle and Management

- **Lifecycle:** `Pending` -> `Running` -> `Succeeded`/`Failed`/`Unknown`
- **Container Lifecycle:** `Waiting` -> `Running` -> `Terminated`
- **Restart Policies:** `always`, `OnFailure`, `Never`

#### Inspecting Pods

```bash
kubectl describe pods hazelcast
kubectl describe pods hazelcast | grep Image:
```

#### Logs

```bash
kubectl logs hazelcast
```

#### Executing Commands

```bash
kubectl exec -it hazelcast -- /bin/bash
```

### Temporary and Network Info

- **Run temporary pod:**

  ```bash
  kubectl run busybox --image=busybox:1.37.0 --rm -it --restart=Never -- env
  ```

- **Find Pod IP:**

  ```bash
  kubectl get pod nginx -o wide
  # OR
  kubectl get pod nginx -o yaml
  ```

**Note:** Each node gets a subnet. Each pod gets a unique IP from the [[Topic - Networking|networking]] lifecycle manager (`kube-proxy`) along with DNS and CNI.

### Pod Configuration

#### Environment Variables

Defined in `spec.containers[].env`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: spring-boot-app
spec:
  containers:
  - name: spring-boot-app
    image: springio/gs-spring-boot-docker
    env:
    - name: SPRING_PROFILES_ACTIVE
      value: dev
    - name: VERSION
      value: '1.5.3'
```

#### Command and Arguments

Maps to `ENTRYPOINT` and `CMD` in Docker.

**Imperative:**

```bash
kubectl run mypod --image=busybox:1.36.1 -o yaml --dry-run=client \
  -- /bin/sh -c "while true; do date; sleep 10; done"
```

**Declarative:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: busybox:1.36.1
    command: ["/bin/sh"]
    args: ["-c", "while true; do date; sleep 10; done"]
```

### Namespace Management

- **Switch namespace for current context:**

  ```bash
  kubectl config set-context --current --namespace=<namespace>
  ```

- **Check current namespace:**

  ```bash
  kubectl config view --minify | grep namespace:
  ```

---
**Topics:** [[Topic - Architecture]], [[Topic - Networking]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
