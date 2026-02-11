# CKA Hot Tips & Tactics (Copilot Edition)

These are “points-per-minute” tactics: reduce typing, reduce mistakes, and maximize partial credit when you’re under the clock.

---

## 1) Speed setup that actually pays off

### Minimal aliases (portable + safe)

Put these in your shell for the exam session:

```bash
alias k=kubectl
export do="--dry-run=client -o yaml"
export now="--force --grace-period=0"
```

### Two killer flags you should *default* to

- Wide output when you’re hunting scheduling/network issues:
  - `k get pod -o wide`
- Namespace targeting without switching context (safer than you think under stress):
  - `k -n <ns> get pod`

> Switching context namespace is fast, but `-n` avoids “oops I forgot I was in kube-system” mistakes.

---

## 2) YAML workflows: when to generate vs when to patch

### Use `--dry-run=client -o yaml` when

- Creating new objects from scratch (Deployments, Jobs, Services, Ingress, NP)
- You want a “known-good” schema that matches your cluster version

### Use `kubectl patch` when

- It’s a single-field change and you don’t want to fight an editor

Examples:

```bash
# Fix a service selector quickly
k -n team1 patch svc api -p '{"spec":{"selector":{"app":"api"}}}'

# Add a toleration (merge patch)
k patch deploy web -p '{"spec":{"template":{"spec":{"tolerations":[{"key":"dedicated","operator":"Equal","value":"gpu","effect":"NoSchedule"}]}}}}'
```

### Use `kubectl set` for “high ROI” changes

```bash
k set image deploy/myapp myapp=nginx:1.27.1
k set resources deploy/myapp -c myapp --requests=cpu=100m,memory=128Mi --limits=cpu=200m,memory=256Mi
k set env deploy/myapp LOG_LEVEL=debug
```

---

## 3) The “selectors first” rule (services, networkpolicies, and scoring)

Before debugging *anything* in networking, verify selectors/labels:

```bash
k get pod --show-labels
k get svc -o yaml | sed -n '/selector:/,/ports:/p'
k get ep <svc-name>
```

If endpoints are empty:

- It’s almost always **selector mismatch** or pods are not Ready.

---

## 4) Debugging shortcuts that win time

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

## 5) JSONPath + go-templates: find exactly what you need

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

---

## 6) NetworkPolicy mental model (avoid classic mistakes)

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

## 7) Storage: the 4 checks for “PVC stuck Pending”

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

## 8) RBAC: don’t overthink—use `auth can-i`

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

## 9) Node & scheduling: fast triage

### Pod Pending checklist

```bash
k describe pod <pod> | sed -n '/Events:/,$p'
k get nodes
k describe node <node> | sed -n '/Taints:/,/Conditions:/p'
```

Typical causes:

- Insufficient CPU/memory
- Node taints + missing tolerations
- NodeSelector / affinity mismatch
- PVC not bound

### Labels/taints with zero YAML

```bash
k label node <node> disktype=ssd
k taint node <node> dedicated=team1:NoSchedule
k taint node <node> dedicated=team1:NoSchedule-   # remove
```

---

## 10) Upgrades & control plane (if it shows up)

If you get an upgrade question, time-sinks are usually:

- forgetting to drain/uncordon
- not aligning kubelet/kubectl versions as required
- missing package repo steps (depends on distro)

High-level sequence (conceptual):

1. `k drain <node> --ignore-daemonsets --delete-emptydir-data`
2. Upgrade control plane components (per instructions)
3. Upgrade kubelet on node
4. `k uncordon <node>`

Don’t improvise commands; follow the distro-specific task text.

---

## 11) “Write output to file” tasks: don’t lose points on formatting

If asked to write *exactly* something to `/path/to/file`:

- Prefer `-o jsonpath=...` or `-o custom-columns=... --no-headers`
- Always redirect with `>` (not `>>`) unless explicitly told to append
- Confirm quickly:

  ```bash
  cat /path/to/file
  ```

---

## 12) Time management tactics

- **Do the fast wins first**: create objects, fix obvious selector typos, simple RBAC.
- **Park hard problems** after ~6–8 minutes:
  - Write down what you tried in a scratch buffer.
  - Move on and come back with fresh eyes.
- **Validate in the simplest way**:
  - If it’s networking: `endpoints`, then `port-forward`, then in-cluster curl.
  - If it’s scheduling: events + taints.
  - If it’s storage: PVC events + SC.

---

## 13) Quick “before you submit” checklist

- Resource exists in the correct namespace
- Labels/selectors match (svc/dep/pod/np)
- Pod is Ready (not just Running)
- Files required by the question actually exist and have content
- No leftover debug pods in critical namespaces (unless harmless)

---

### Tiny morale boost

You don’t need perfection—just correct, verifiable outcomes. Aim for “works now” over “beautiful YAML forever”.
