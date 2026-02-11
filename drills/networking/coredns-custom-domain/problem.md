# CoreDNS: Add Custom Domain Resolution

The cluster DNS needs to be updated to support a custom domain suffix.

Your tasks:

1. Backup the current CoreDNS ConfigMap to `/home/vagrant/coredns-backup.yaml`
2. Update the CoreDNS configuration so that DNS resolution works for both:
   - Standard: `SERVICE.NAMESPACE.svc.cluster.local`
   - Custom: `SERVICE.NAMESPACE.svc.internal.company`
3. Test your configuration from a Pod

## Verification

From any Pod, both of these should resolve to the same IP:

```bash
nslookup kubernetes.default.svc.cluster.local
nslookup kubernetes.default.svc.internal.company
```

## Information

- CoreDNS ConfigMap is in namespace `kube-system`
- The ConfigMap is named `coredns`
- You may need to restart CoreDNS pods after changing the ConfigMap

**Hint**: Look at the Corefile and duplicate/modify the kubernetes plugin block with a different zone.
