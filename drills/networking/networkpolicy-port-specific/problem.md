# NetworkPolicy Port Specific

## Objective

In the namespace `restricted-net`, create a NetworkPolicy named `allow-db-port` that restricts ingress traffic to pods labeled `app=database`.
The policy should **ONLY** allow TCP traffic on port `6379`.
Ensure that the client pod (labeled `app=client`) can reach the database on port 6379, but **restrictions must apply** (i.e. default deny behavior for other ports or sources is established).

The setup script has already created the namespace and pods.

## Requirements

- Namespace: `restricted-net`
- NetworkPolicy Name: `allow-db-port`
- Target Pods: `app=database`
- Allowed Traffic: TCP port `6379`
- **Hint**: NetworkPolicies are additive, but selecting a pod isolates it. Ensure you select the target pods.
