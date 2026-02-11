---
tags: ["type/tactic", "source/copilot", "status/seed"]
aliases: ["RBAC: don’t overthink—use `auth can-i`"]
---

# Tactic - RBAC: don’t overthink—use `auth can-i`

RBAC tasks often boil down to:

- Create Role/ClusterRole
- Bind it to a ServiceAccount/User
- Prove permissions

Fast feedback loop:

```bash
k auth can-i get pods -n <ns> --as=system:serviceaccount:<ns>:<sa>
k auth can-i create deployments -n <ns> --as=system:serviceaccount:<ns>:<sa>
```

When building rules, prefer least privilege (exams love “only verbs X on resources Y”):

- verbs: `get,list,watch,create,update,patch,delete`
- resources: `pods`, `deployments`, `configmaps`, etc.
- API groups: `""` (core), `apps`, `batch`, `rbac.authorization.k8s.io`

---

---
**Topics:** [[Topic - Networking]], [[Topic - Security]], [[Topic - Workloads]]
