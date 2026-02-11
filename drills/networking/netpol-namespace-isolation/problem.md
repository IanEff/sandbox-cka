# Namespace Isolation with NetworkPolicies

You are securing a sensitive application.

1. In namespace `restricted-2`, there is a Pod named `sensitive-db` (listening on TCP 6379) and a web server `public-web` (listening on TCP 80).
2. Implement a `NetworkPolicy` named `restrict-access` in namespace `restricted-2` that:
    * Denies ALL ingress traffic to Pods in `restricted-2` by default.
    * Allows ingress traffic to `sensitive-db` (port 6379) ONLY from Pods in the `default` namespace that have the label `role: trusted`.
    * Does NOT restrict traffic to `public-web` (allowing all sources to access port 80).

> Tip: You may need multiple policies or a single complex one. Ensure you don't accidentally block the `public-web` if you use a "default deny" policy.
