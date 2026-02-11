# Networking: Deny All Ingress

The namespace `secure-net` contains sensitive workloads.

1. Create a `NetworkPolicy` named `default-deny` in the `secure-net` namespace.
2. The policy should deny **all** incoming (ingress) traffic to all pods in the namespace.
3. Do not block egress traffic.
4. Verify that the `intruder` pod in the `default` namespace can no longer access port 80 of the `backend` pod in `secure-net`.
