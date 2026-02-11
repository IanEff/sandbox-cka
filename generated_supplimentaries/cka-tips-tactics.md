# CKA Exam Tips and Tactics

## Creating pod definitions with kubectl

```bash
kubectl run web-app \
  --image=nginx:1.28.0 \
  -n app-team \
  --dry-run=client -o yaml > web-app.yaml

# Useful base images for troubleshooting:
busybox:1.37.0
nginx:1.27.1
curlimages/curl:8.1.2
```

## kubectl verbosity / VALIDITY

```bash
# ALWAYS kubectl get immediately after an apply to validate success
kubectl get pods -n producti0n -v=9

# Server-side dry-run actually validates
kubectl apply -f deployment.yaml --dry-run=server -v=1

# Check exit codes explicitly
echo $?

# See what would change before applying
kubectl diff -f deployment.yaml  # (probably outside scope)

# Validate labels exist before using selectors
kubectl get pods --show-labels
```

## Namespace sanity checks

```bash
# List all namespaces to catch typos
kubectl get ns

# Set namespace for current context (saves typing -n constantly)
kubectl config set-context --current --namespace=team-awesome

# View current namespace
kubectl config view --minify | grep namespace:

# Don't forget to switch back to default after!
kubectl config set-context --current --namespace=default
```

## Fast resource inspection

```bash
# Wide output shows NODE and IP - crucial for scheduling questions
kubectl get pods -o wide

# Get specific field without parsing YAML
kubectl get pod nginx -o jsonpath='{.spec.nodeName}'
kubectl get pod nginx -o jsonpath='{.status.podIP}'

# Events sorted by time (last event at bottom)
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n kube-system --sort-by='.lastTimestamp'

# Describe shows events at the bottom - read those first
kubectl describe pod nginx | tail -20
```

## Debugging pod failures

```bash
# Get pod status in one line
kubectl get pod nginx -o jsonpath='{.status.phase}'

# See container statuses
kubectl get pod nginx -o jsonpath='{.status.containerStatuses[*].state}'

# Logs from previous container (if it restarted)
kubectl logs nginx -c container-name --previous

# Logs from all containers in pod
kubectl logs nginx --all-containers=true

# Follow logs in real-time
kubectl logs -f nginx
```

## RBAC verification

```bash
# Check if YOU can do something
kubectl auth can-i create deployments --namespace=dev

# Check if ANOTHER USER can do something
kubectl auth can-i list pods --as=alice --namespace=prod

# List all permissions for a user
kubectl auth can-i --list --as=alice

# Verify service account permissions
kubectl auth can-i list pods --as=system:serviceaccount:default:my-sa
```

## Fast object deletion (exam time-saver)

```bash
# Force immediate deletion (don't wait 30s grace period)
kubectl delete pod nginx --now

# Delete without confirmation prompts
kubectl delete pod nginx --force --grace-period=0

# Delete all pods matching label
kubectl delete pods -l app=nginx --now
```

## Resource requirements shortcuts

```bash
# Create deployment with resource requests imperatively
kubectl create deployment web --image=nginx \
  --dry-run=client -o yaml > web.yaml
# Then edit web.yaml to add resources section

# Remember the format:
# resources:
#   requests:
#     cpu: "100m"      # 100 millicores
#     memory: "128Mi"  # 128 mebibytes
#   limits:
#     cpu: "200m"
#     memory: "256Mi"

# Common CPU values:
# 100m = 0.1 core = 10% of 1 core
# 500m = 0.5 core = 50% of 1 core
# 1    = 1 core   = 100% of 1 core

# Common memory values:
# Mi = mebibyte (1024^2 bytes)
# Gi = gibibyte (1024^3 bytes)
# 128Mi, 256Mi, 512Mi, 1Gi, 2Gi
```

## ConfigMap/Secret creation shortcuts

```bash
# From literal values (fastest)
kubectl create configmap app-config \
  --from-literal=DB_HOST=mysql \
  --from-literal=DB_PORT=3306

kubectl create secret generic db-creds \
  --from-literal=username=admin \
  --from-literal=password=secret

# From file (for structured data)
kubectl create configmap app-config --from-file=config.json

# From env file (KEY=value format)
kubectl create configmap app-config --from-env-file=database.env

# Check what's in them WITHOUT decoding base64
kubectl get secret db-creds -o jsonpath='{.data.password}' | base64 -d
```

## Editing live objects (when you mess up)

```bash
# Edit in your $EDITOR
kubectl edit pod nginx

# Patch specific field (faster than edit)
kubectl patch deployment web -p '{"spec":{"replicas":5}}'

# Replace (useful if edit validation fails)
kubectl get pod nginx -o yaml > nginx.yaml
# edit nginx.yaml
kubectl replace -f nginx.yaml --force
```

## Label management

```bash
# Add label
kubectl label pod nginx env=prod

# Remove label (note the minus)
kubectl label pod nginx env-

# Overwrite existing label
kubectl label pod nginx env=staging --overwrite

# Label nodes (for nodeSelector/affinity)
kubectl label node worker-1 disk=ssd
kubectl label node worker-1 disk-  # remove it
```

## Deployment rollout management

```bash
# Watch rollout in real-time
kubectl rollout status deployment/web

# See rollout history
kubectl rollout history deployment/web

# See specific revision details
kubectl rollout history deployment/web --revision=2

# Rollback to previous revision
kubectl rollout undo deployment/web

# Rollback to specific revision
kubectl rollout undo deployment/web --to-revision=1

# Pause rollout (for canary testing)
kubectl rollout pause deployment/web

# Resume rollout
kubectl rollout resume deployment/web

# Add change-cause annotation (shows up in history)
kubectl annotate deployment web \
  kubernetes.io/change-cause="Updated to version 1.2.3"
```

## Node operations

```bash
# List nodes with labels
kubectl get nodes --show-labels

# Drain node (before maintenance)
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data

# Cordon node (mark unschedulable, don't evict pods)
kubectl cordon worker-1

# Uncordon node (mark schedulable again)
kubectl uncordon worker-1

# Check node capacity and allocatable resources
kubectl describe node worker-1 | grep -A 5 "Allocated resources"
```

## Context and cluster management

```bash
# List available contexts
kubectl config get-contexts

# Switch context
kubectl config use-context cluster-admin@kubernetes

# View current context
kubectl config current-context

# Get cluster info
kubectl cluster-info
```

## Copy files to/from pods

```bash
# Copy FROM pod
kubectl cp nginx:/var/log/nginx/access.log ./access.log

# Copy TO pod
kubectl cp ./config.json nginx:/etc/app/config.json

# Specify container in multi-container pod
kubectl cp nginx:/var/log/app.log ./app.log -c sidecar
```

## Quick verification patterns

```bash
# After creating pod: verify it's running and on correct node
kubectl get pod nginx -o wide

# After creating deployment: verify replica count
kubectl get deployment web
kubectl get replicaset  # check underlying RS

# After creating service: verify endpoints exist
kubectl get svc web
kubectl get endpoints web

# After creating configmap/secret: verify keys exist
kubectl get configmap app-config -o jsonpath='{.data}'
kubectl get secret db-creds -o jsonpath='{.data}'

# After applying RBAC: verify with auth can-i
kubectl auth can-i <verb> <resource> --as=<user> -n <namespace>
```

## Common exam gotchas

```bash
# ALWAYS check the question namespace!
# Questions will be explicit: "in namespace dev", "in namespace production"

# If creating objects imperatively, remember -n
kubectl run nginx --image=nginx -n dev

# If no namespace specified, assume 'default'

# Resource names are case-sensitive
# Pod named "Nginx" ≠ pod named "nginx"

# YAML indentation matters (2 spaces per level)
# Use kubectl explain to check structure:
kubectl explain pod.spec.containers.resources

# For multi-line commands, check for shell compatibility
# exam likely uses bash, so use bash syntax

# Container images: use specific tags, not 'latest'
nginx:1.27.1  # GOOD
nginx:latest  # BAD (version may change)
```

## Keyboard shortcuts (time savers)

```bash
# Set aliases in exam (if allowed - check current exam rules)
alias k=kubectl
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kdp='kubectl describe pod'
alias kd='kubectl describe'

# Use shell history extensively
# Up arrow, Ctrl+R for search

# Tab completion should be enabled
kubectl get po<TAB>  # completes to 'pods'
kubectl get pods ngi<TAB>  # completes to pod name
```

## When shit's really broken

```bash
# Check control plane pods (if you have access)
kubectl get pods -n kube-system

# Check node status
kubectl get nodes
kubectl describe node <nodename>

# Look for admission controller errors
kubectl get events -A | grep -i error

# Check if API server is responding
kubectl version

# If pod won't schedule:
kubectl describe pod <podname> | grep -A 10 Events

# If pod is stuck in Pending:
# - Check node resources: kubectl describe node
# - Check PVC status: kubectl get pvc
# - Check node taints: kubectl describe node | grep Taint
# - Check pod events: kubectl describe pod

# If pod is CrashLoopBackOff:
kubectl logs <podname> --previous
kubectl describe pod <podname>
```

## Resource type shortcuts

```bash
# Full name vs short name:
po = pods
svc = services
deploy = deployments
rs = replicasets
ns = namespaces
cm = configmaps
sa = serviceaccounts
pv = persistentvolumes
pvc = persistentvolumeclaims
no = nodes
ing = ingresses
netpol = networkpolicies
```

## Documentation lookup (allowed during exam)

```bash
# Bookmark these in exam browser:
# https://kubernetes.io/docs/
# https://kubernetes.io/docs/reference/kubectl/

# Search patterns that work well:
# "kubernetes <resource-type> example"
# "kubernetes <resource-type> yaml"
# kubernetes.io search is your friend

# Use kubectl explain for API structure:
kubectl explain pod.spec
kubectl explain deployment.spec.template.spec.containers
kubectl explain pod.spec.containers.resources
```

---

## Pre-exam ritual

1. `kubectl get nodes` - verify cluster is up
2. `kubectl config get-contexts` - identify available contexts
3. Set bash aliases if allowed
4. Open docs in browser, bookmark key pages
5. Take a deep breath, you got this

## During exam

1. Read the question TWICE - note the namespace
2. Switch context if needed
3. Do the task
4. **IMMEDIATELY** verify with `kubectl get`
5. Move on, don't second-guess