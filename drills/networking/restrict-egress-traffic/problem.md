# Restrict Egress Traffic

A secure pod requires strict network controls using Cilium Network Policies. It should only be allowed to communicate with DNS services and nothing else.

Requirements:

- Create a namespace `secure-net`
- Deploy a pod named `restricted-pod` using `busybox` (command: `sleep 3600`)
- Create a NetworkPolicy named `deny-external-egress` in `secure-net`
- The policy must apply to `restricted-pod`
- The policy must ALLOW egress to UDP port 53 (DNS)
- The policy must DENY all other egress traffic (e.g., cannot ping 8.8.8.8)
- Verify that DNS resolution works but other outbound traffic is blocked

Current state: No resources currently exist.
