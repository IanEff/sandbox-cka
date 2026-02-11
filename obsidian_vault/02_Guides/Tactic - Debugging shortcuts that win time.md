---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["Debugging shortcuts that win time"]
---

# Tactic - Debugging shortcuts that win time

### One-liners you should memorize

```bash
# See why a pod won't schedule / why it restarts
k describe pod <pod>

# Container logs (and previous crash)
k logs <pod> -c <container>
k logs <pod> -c <container> --previous

# Watch events in a namespace (gold during troubleshooting)
k -n <ns> get events --sort-by=.metadata.creationTimestamp
```

### Ephemeral “toolbox” pods for DNS + curl

If allowed on your environment, this is huge for Service/DNS issues:

```bash
k run tmp --image=busybox:1.36 --restart=Never -it --rm -- sh
# inside:
nslookup kubernetes.default
wget -qO- http://<svc>:<port>
```

If BusyBox lacks curl/wget in your image, `alpine` + `apk add curl` is a fallback.

---

---
**Topics:** [[Topic - Networking]], [[Topic - Troubleshooting]], [[Topic - Workloads]]
