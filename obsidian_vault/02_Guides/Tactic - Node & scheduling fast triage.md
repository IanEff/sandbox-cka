---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["Node & scheduling: fast triage"]
---

# Tactic - Node & scheduling: fast triage

### Pod Pending checklist

```bash
k describe pod <pod> | sed -n '/Events:/,$p'
k get nodes
k describe node <node> | sed -n '/Taints:/,/Conditions:/p'
```

Typical causes:

- Insufficient CPU/memory
- Node taints + missing tolerations
- NodeSelector / affinity mismatch
- PVC not bound

### Labels/taints with zero YAML

```bash
k label node <node> disktype=ssd
k taint node <node> dedicated=team1:NoSchedule
k taint node <node> dedicated=team1:NoSchedule-   # remove
```

---

---
**Topics:** [[Topic - Architecture]], [[Topic - Storage]], [[Topic - Workloads]]
