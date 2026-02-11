---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Troubleshooting Applications", "Chapter 21 - Troubleshooting Applications"]
---

# Concept - [[Topic - Troubleshooting|Troubleshooting]] Applications

1. **Check Status:** `kubectl get pods`
2. **Events:** `kubectl get events --sort-by='.lastTimestamp'`
3. **Logs:** `kubectl logs <pod-name>`
4. **Interactive Shell:** `kubectl exec -it <pod> -- /bin/sh`
5. **Ephemeral Debugging:** `kubectl debug -it <pod> --image=busybox`
6. **Port Forwarding:** `kubectl port-forward pod/<pod> 8080:80`
7. **Resource Usage:** `kubectl top pod`

---
**Topics:** [[Topic - Networking]], [[Topic - Tooling]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
