---
tags: ["type/concept", "source/notes_md", "status/seed"]
aliases: ["Chapter 20 - Network Policies", "Network Policies"]
---

# Concept - Network Policies

Controls inter-pod communication. Requires a CNI that supports policies (e.g., Calico, Flannel).

Pod isolation:
isolation for egress
ditto ingress

- by default pod is `non-isolated` for `egress`-- all outbound connections allowed
- by default pod is `non-isolated` for `ingress`-- all inbound connections allowed

```For a connection from a source pod to a destination pod to be allowed, both the egress policy on the source pod and the ingress policy on the destination pod need to allow the connection. If either side does not allow the connection, it will not happen.```

**Allow Specific Ingress Example:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-allow
spec:
  podSelector:              # Matches pods **TO WHICH NETWORKPOLICY APPLIES**
    matchLabels:
      app: api
  ingress:
  - from:                   # These guys are allowed to **SEND TO** the pod
    - podSelector:          
        matchLabels:
          app: frontend
```

**Default Deny All:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes: ["Ingress", "Egress"]
```

---
**Topics:** [[Topic - Networking]], [[Topic - Workloads]]
