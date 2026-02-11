# Node Cordon/Uncordon

**Drill Goal:** Manage node scheduling availability.

## Problem

Mark the node `ubukubu-node-1` as **unschedulable** to prevent new Pods from being scheduled onto it.
Do **not** drain the node; existing Pods should remain running.

## Validation

Verify that `ubukubu-node-1` has `SchedulingDisabled` status.
