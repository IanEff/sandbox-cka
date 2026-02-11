---
tags: ["type/guide", "source/gemini", "status/seed"]
aliases: ["The "Editing" Decision Tree"]
---

# Guide - The "Editing" Decision Tree

*When to use what command:*

| Scenario | Tool | Why? |
| :--- | :--- | :--- |
| **Fixing a typo / changing an image** | `kubectl edit` | Fast. Opens live object. Saves instantly. |
| **Changing a field that can't be edited (e.g., removing a container)** | `export do` + `replace` | `k get pod x $do > p.yaml` -> `k delete pod x` -> Edit file -> `k apply -f p.yaml` |
| **Adding a complex Taint/Label** | `kubectl taint/label` | Don't edit YAML for this. Use the imperative commands. |
| **Scaling** | `kubectl scale` | Fastest way to change replicas. |

---

---
**Topics:** [[Topic - Networking]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
