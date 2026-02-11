# Drill: The Persnickety Node

## Scenario

The `picky-app` Deployment in the `affinity-test` namespace demands high-performance storage. It uses Node Affinity to ensure it only runs on nodes labeled with `disk=ssd`. Currently, no nodes meet this criteria, so the Pod is stuck in Pending.

## Task

1. Verify the reason why the `picky-app` Pod is Pending.
2. Label one of the cluster nodes with `disk=ssd` to satisfy the affinity requirement.
3. Ensure the Pod gets scheduled and enters the `Running` state.

## Validation

Run `drill verify workloads/node-affinity-required` to check your work.
