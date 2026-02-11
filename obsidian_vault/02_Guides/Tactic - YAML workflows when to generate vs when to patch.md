---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["YAML workflows: when to generate vs when to patch"]
---

# Tactic - YAML workflows: when to generate vs when to patch

### Use `--dry-run=client -o yaml` when

- Creating new objects from scratch (Deployments, Jobs, [[Concept - Services|Services]], Ingress, NP)
- You want a “known-good” schema that matches your cluster version

### Use `kubectl patch` when

- It’s a single-field change and you don’t want to fight an editor

Examples:

```bash
# Fix a service selector quickly
k -n team1 patch svc api -p '{"spec":{"selector":{"app":"api"}}}'

# Add a toleration (merge patch)
k patch deploy web -p '{"spec":{"template":{"spec":{"tolerations":[{"key":"dedicated","operator":"Equal","value":"gpu","effect":"NoSchedule"}]}}}}'
```

### Use `kubectl set` for “high ROI” changes

```bash
k set image deploy/myapp myapp=nginx:1.27.1
k set resources deploy/myapp -c myapp --requests=cpu=100m,memory=128Mi --limits=cpu=200m,memory=256Mi
k set env deploy/myapp LOG_LEVEL=debug
```

---

---
**Topics:** [[Topic - Networking]], [[Topic - Security]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
