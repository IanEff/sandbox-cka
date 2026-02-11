---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["Storage: the 4 checks for “PVC stuck Pending”"]
---

# Tactic - [[Topic - Storage|Storage]]: the 4 checks for “PVC stuck Pending”

When a PVC won’t bind, check in this order:

1. PVC events:

   ```bash
   k describe pvc <pvc>
   ```

2. StorageClass:

   ```bash
   k get sc
   k get sc <name> -o yaml
   ```

3. PVs available:

   ```bash
   k get pv
   ```

4. AccessModes & capacity mismatches:
   - `ReadWriteOnce` vs `ReadWriteMany`
   - requested size > PV size

Bonus: If dynamic provisioning is expected but no PV appears, suspect wrong `storageClassName`.

---

---
**Topics:** [[Topic - Storage]]
