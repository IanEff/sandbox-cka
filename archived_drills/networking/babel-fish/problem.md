# Babel Fish

The pod `arthur-dent` is trying to understand the local dialect of the cluster, but it seems to have a fish stuck in its ear that isn't working quite right. It cannot resolve any hostnames.

**Your Task:**
Fix the DNS configuration of the `arthur-dent` pod so it can resolve `kubernetes.default`.

**Verification:**
Run `nslookup kubernetes.default` inside the pod to verify.
