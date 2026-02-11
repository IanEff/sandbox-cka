---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["The “selectors first” rule (services, networkpolicies, and scoring)"]
---

# Tactic - The “selectors first” rule ([[Concept - Services|services]], networkpolicies, and scoring)

Before debugging *anything* in [[Topic - Networking|networking]], verify selectors/labels:

```bash
k get pod --show-labels
k get svc -o yaml | sed -n '/selector:/,/ports:/p'
k get ep <svc-name>
```

If endpoints are empty:

- It’s almost always **selector mismatch** or pods are not Ready.

---

---
**Topics:** [[Topic - Networking]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
