---
tags: ["type/guide", "source/gemini", "status/seed"]
aliases: ["The "Fixing" Loop (Troubleshooting)"]
---

# Guide - The "Fixing" Loop ([[Topic - Troubleshooting|Troubleshooting]])

*Used for: "This service isn't working..." or "Node is NotReady"*

### Scenario A: The App is Broken (The "Outside-In" Flow)

Don't guess. Follow the path of the traffic.

1. **Check Service:** `k get svc` -> Is the ClusterIP/Port correct?
2. **Check Endpoints:** `k get ep <service-name>`
    * **If EMPTY:** The Service selector does not match the Pod labels. **STOP.** Fix the Service selector.
    * **If POPULATED:** Traffic is getting to the pod. The issue is the Pod itself.
3. **Check Pod Status:** `k get pod`
    * `ImagePullBackOff` -> **Strategy:** `edit`. It's usually a typo in the image name.
    * `CrashLoopBackOff` -> **Strategy:** `logs`. The app is starting but dying (config error, missing secret).
    * `Pending` -> **Strategy:** `describe`. It's waiting for resources, scheduling (taints/tolerations), or a PVC.

### Scenario B: The Node is Broken (The "System" Flow)

When `kubectl` can't help you because the API server is down or the node is disconnected.

1. **SSH In:** `ssh <node-name>`
2. **Check Kubelet:** The Kubelet is the captain of the node.
    * `systemctl status kubelet` -> Is it running?
    * `journalctl -u kubelet | tail -n 20` -> Why is it unhappy? (Look for certificate errors or config path errors).
3. **Check Containers (Runtime):**
    * `crictl ps` -> Are the control plane static pods (etcd, api-server) actually running?
    * `crictl logs <container-id>` -> If the API server container is crashing, `kubectl` won't work, but this will.

---

---
**Topics:** [[Topic - Architecture]], [[Topic - Networking]], [[Topic - Security]], [[Topic - Storage]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
