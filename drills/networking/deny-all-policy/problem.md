# Network Policy - Allow List

In the namespace `secure-drill`, there are three pods:
- `api` (labels: `app=api`) - Exposed on port 80.
- `frontend` (labels: `app=frontend`)
- `intruder` (labels: `app=intruder`)

Currently, all traffic is allowed.
Create a NetworkPolicy named `api-protection` in that namespace that:
1. Denies all ingress traffic to `app=api` by default.
2. Allows ingress traffic to `app=api` ONLY from Pods with label `app=frontend`.
3. Does not affect egress traffic.
