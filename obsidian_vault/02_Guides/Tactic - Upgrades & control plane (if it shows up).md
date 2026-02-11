---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["Upgrades & control plane (if it shows up)"]
---

# Tactic - Upgrades & control plane (if it shows up)

If you get an upgrade question, time-sinks are usually:

- forgetting to drain/uncordon
- not aligning kubelet/kubectl versions as required
- missing package repo steps (depends on distro)

High-level sequence (conceptual):

1. `k drain <node> --ignore-daemonsets --delete-emptydir-data`
2. Upgrade control plane components (per instructions)
3. Upgrade kubelet on node
4. `k uncordon <node>`

Don’t improvise commands; follow the distro-specific task text.

---

---
**Topics:** [[Topic - Architecture]], [[Topic - Tooling]], [[Topic - Workloads]]
