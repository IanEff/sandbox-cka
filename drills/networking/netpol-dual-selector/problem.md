# NetworkPolicy Dual Selector

**Drill Goal:** Create a complex NetworkPolicy using both logical AND and OR conditions.

## Problem

Use the namespace `restricted-net`.
Create a NetworkPolicy named `secure-access`.
It should allow **Ingress** traffic to Pods with the label `app=sensitive`.

The allowed traffic should come **only** from:
1.  Pods in the **SAME** namespace (`restricted-net`) that have **BOTH** labels `role=admin` AND `access=full`.
2.  **ANY** Pod from the namespace `monitoring`.

## Validation

Verify that the NetworkPolicy is correctly created and enforces the described rules.
