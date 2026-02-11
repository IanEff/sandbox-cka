# Node Label Taint

**Drill Goal:** Manage Node metadata (Labels and Taints).

## Problem

1.  Identify the node named `ubukubu-node-1`.
2.  **Label** it with `hardware=gpu`.
3.  **Taint** it with `dedicated=rendering:NoSchedule`.

## Validation

Verify that the node has the specified label and taint exists.
