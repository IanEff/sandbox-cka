# Scheduler Crash Diagnosis

## Objective
Diagnose why new Pods are remaining in the `Pending` state and fix the underlying issue.

## Instructions
1.  A Pod named `test-pod` has been created in the `default` namespace but is stuck in `Pending`.
2.  Investigate the core cluster components to determine why scheduling is not occurring.
3.  Fix the issue so that `test-pod` (and future pods) can be scheduled and reach the `Running` state.

## Verification
The Pod `test-pod` should be in the `Running` state.
