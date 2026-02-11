---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["JSONPath + go-templates: find exactly what you need"]
---

# Tactic - JSONPath + go-templates: find exactly what you need

When tasks ask for “output X to file Y”, JSONPath is usually fastest.

```bash
# Node internal IPs
k get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}'

# Pod images in a namespace
k -n <ns> get pod -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{" "}{end}{"\n"}{end}'
```

Tip: If JSONPath is being painful, use:

```bash
k get <thing> -o yaml > /tmp/x.yaml
```

…and grep your way out.

# Tactic - JSONPath sorting

```bash
kubectl get pods --sort-by=.status.startTime -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.startTime}{"\n"}{end}'
```


---

---
**Topics:** [[Topic - Architecture]], [[Topic - Tooling]], [[Topic - Workloads]]
