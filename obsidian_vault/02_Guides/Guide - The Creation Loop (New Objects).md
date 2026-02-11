---
tags: ["type/guide", "source/gemini", "status/seed"]
aliases: ["The "Creation" Loop (New Objects)"]
---

# Guide - The "Creation" Loop (New Objects)

*Used for: "Create a deployment/pod/service..."*

**The Strategy:** Never write YAML from scratch.

1. **Generate:** `k create deploy my-dep --image=nginx --replicas=3 $do > deploy.yaml`
2. **Verify:** `cat deploy.yaml` (Quick eyeball check)
3. **Apply:** `k apply -f deploy.yaml`
4. **Validate:** `k get deploy` (Did it actually work?)

**Shortcuts:**

* **Pod:** `k run`
* **Deployment:** `k create deploy`
* **Service:** `k expose` (Fastest way to create a service for an existing pod/deploy)
  * *Example:* `k expose deploy my-dep --port=80 --target-port=8080 --name=my-svc $do`
* **CronJob:** `k create cronjob`

---

---
**Topics:** [[Topic - Networking]], [[Topic - Workloads]]
