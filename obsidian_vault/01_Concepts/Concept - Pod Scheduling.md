---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Pod Scheduling", "Chapter 14 - Pod Scheduling"]
---

# Concept - Pod Scheduling

**The Scheduler process:**

1. **Filter:** Find nodes with enough resources.
2. **Score:** Rank capable nodes.
3. **Bind:** Assign the pod to the best node.

**Identify node allocation:**

```bash
kubectl get pod nginx -o wide
# OR
kubectl describe pod nginx | grep Node:
```

### Scheduling Options

#### 1. Node Selector

Uses labels for simple placement.

```bash
kubectl label node node01 disk=ssd
```

```yaml
spec:
  nodeSelector:
    disk: ssd
```

#### 2. Node Affinity

More expressive than node selectors.

```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disk
            operator: In
            values: ["ssd", "hdd"]
```

**Affinity Operators:** `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt`.

### Taints and Tolerations

- **Taint:** Assigned to a **Node** to repel pods.
- **Toleration:** Assigned to a **Pod** to allow it to be scheduled on a tainted node.

**Taint Effects:**

- `NoSchedule`: No new pods unless they tolerate.
- `PreferNoSchedule`: Scheduler tries to avoid the node.
- `NoExecute`: Existing pods are evicted if they don't tolerate.

**Taint Command:**

```bash
kubectl taint node node01 special=true:NoSchedule
```

**Pod Toleration YAML:**

```yaml
spec:
  tolerations:
  - key: "special"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

### Pod Topology Spread Constraints

Distributes pods across topology domains (e.g., zones).

```yaml
spec:
  topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app: web
```

- **Note:** These are only checked during initial scheduling, they don't rebalance.

---
**Topics:** [[Topic - Architecture]], [[Topic - Security]], [[Topic - Tooling]], [[Topic - Workloads]]
