---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Primitives and objects", "Chapter 3 - Primitives and objects"]
---

# Concept - Primitives and objects

e.g.

- Pods
- Deployments
- [[Concept - Services|Services]]

### Creating objects

```bash
kubectl run
kubectl create
```

- Fails if resource exists.

### Updating objects

```bash
kubectl edit
```

- Opens editor with the raw config of the live object & applies changes on save
- Note: You can define a `KUBE_EDITOR` if `EDITOR` is being difficult.

```bash
kubectl patch
```

- Directly patches the live object's manifest by way of JSON with the `-p` flag.

### Deleting objects

```bash
kubectl delete pod nginx --now
```

### Declarative object management

- Creates, updates, all with `apply`.
- Keeps track of changes with the key `kubectl.kubernetes.io/last-applied-configuration`.

---
**Topics:** [[Topic - Networking]], [[Topic - Security]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
