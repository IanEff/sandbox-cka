---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Kubernetes breakdown", "Chapter 2 - Kubernetes breakdown"]
---

# Concept - Kubernetes breakdown

- **Control plane node**
  - API server
  - Scheduler
  - Controller manager
    - Watches for change
  - EtcD
    - Key-value store with all k8s cluster data
- **Common node components**
  - kubelet
    - keeps all containers in a pod running
  - kube proxy
    - maintains network rules
  - container runtime

---
**Topics:** [[Topic - Architecture]], [[Topic - Networking]], [[Topic - Security]], [[Topic - Workloads]]
