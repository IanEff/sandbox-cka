---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["Speed setup that actually pays off"]
---

# Tactic - Speed setup that actually pays off

### Minimal aliases (portable + safe)

Put these in your shell for the exam session:

```bash
alias k=kubectl
export do="--dry-run=client -o yaml"
export now="--force --grace-period=0"
```

### Two killer flags you should *default* to

- Wide output when you’re hunting scheduling/network issues:
  - `k get pod -o wide`
- Namespace targeting without switching context (safer than you think under stress):
  - `k -n <ns> get pod`

> Switching context namespace is fast, but `-n` avoids “oops I forgot I was in kube-system” mistakes.

---

---
**Topics:** [[Topic - Networking]], [[Topic - Tooling]], [[Topic - Workloads]]
