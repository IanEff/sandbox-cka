# NetPol Default Deny Egress

**Drill Goal:** Block all outgoing traffic in a namespace unless explicitly allowed.

## Problem

1.  Create a namespace named `secure-egress`.
2.  Create a strict NetworkPolicy named `deny-all-egress` in that namespace.
3.  The policy should **deny all EGRESS** traffic for all Pods in the namespace.
4.  It should NOT affect Ingress traffic.

## Validation

Verify that the NetworkPolicy isolates Egress traffic.
