# Egress Lockdown

In the namespace `restricted`:
1. Create a NetworkPolicy named `egress-lockdown`.
2. It should apply to all pods in the namespace `restricted`.
3. It should only allow egress traffic to:
    - UDP port 53 (DNS)
    - TCP port 53 (DNS)
    - The IP address `1.1.1.1`
    - Deny everything else.

**Note:** The namespace `restricted` and a test pod `test-pod` have been created for you.
