# iptables Traffic Flow

The security team needs to understand how kube-proxy implements Service routing.

1. Create a Deployment named `payment-api` with 2 replicas using image `httpd:2-alpine` in Namespace `finance`
2. Expose it with a ClusterIP Service named `payment-svc` on port 80
3. Capture the Service's ClusterIP and write it to `/opt/course/overlay4/service-ip.txt`
4. On a node (e.g., Control Plane), run `iptables-save` and grep for rules related to `finance/payment-svc`
    * Write the `KUBE-SERVICES` chain rules for this service into `/opt/course/overlay4/service-rules.txt`
    * Find the individual endpoint (`KUBE-SEP`) chains and write them to `/opt/course/overlay4/endpoint-chains.txt`
5. Explain in `/opt/course/overlay4/explanation.txt` (in your own words, 2-3 sentences) why ICMP ping doesn't work to the Service IP but HTTP does.

**Verification**: Your iptables rules should show probability-based load balancing across the 2 Pod endpoints. (Note: if your cluster uses kube-proxy in IPVS mode or Cilium strict replacement, iptables rules might be different or absent. If using Cilium without strict kube-proxy replacement, iptables still exist. If fully Cilium eBPF, check `cilium service list` instead, but for this drill assume standard iptables or note the difference).
