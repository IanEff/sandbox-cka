# Network Policy Lockdown

There was a security incident where an intruder was able to access the whole cluster from a single backend Pod. We need to lockdown traffic in `project-snake`.

## Requirements

Create a NetworkPolicy named `np-backend` in Namespace `project-snake`.

1. It should apply to pods with label `app=backend`.
2. It should **only** allow egress traffic to:
    * Pods with label `app=db1` on TCP port 1111.
    * Pods with label `app=db2` on TCP port 2222.
3. Deny all other egress traffic from the backend pods.
4. Do not disrupt DNS traffic (UDP 53) if not explicitly mentioned, but in a real lockdown, remember DNS. For this drill, strictly follow the requirement: **Only connect to db1:1111 and db2:2222**. (Hint: This might break DNS, which is fine if strict interpretation is requested, but typically minimal DNS is needed. The requirement implies *whitelisting specific application ports*. Usually "only allow X" in CKA implies "deny everything else by default").

**Note**: The database pods (`db1`, `db2`) are listening on the specified ports.
