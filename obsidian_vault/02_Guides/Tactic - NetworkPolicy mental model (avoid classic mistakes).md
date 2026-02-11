---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["NetworkPolicy mental model (avoid classic mistakes)"]
---

# Tactic - NetworkPolicy mental model (avoid classic mistakes)

### Start from “who selects whom”

- `podSelector` selects the pods **this policy applies to**
- `ingress[].from` / `egress[].to` specify who is allowed

### Common exam patterns

- **Default deny ingress** for a namespace:
  - policy selects all pods (`podSelector: {}`) and has no ingress rules
- **Allow from same namespace + specific label**
- **Allow DNS egress to kube-dns** (often required once you deny egress)

DNS egress check items (varies by cluster):

- Namespace: often `kube-system`
- Labels: commonly `k8s-app=kube-dns` or `kubernetes.io/name=CoreDNS`

Always confirm:

```bash
k -n kube-system get pod --show-labels | egrep 'dns|coredns'
k -n kube-system get svc --show-labels | egrep 'dns|coredns'
```

---

---
**Topics:** [[Topic - Networking]], [[Topic - Workloads]]
