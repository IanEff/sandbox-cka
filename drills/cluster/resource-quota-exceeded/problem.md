# Drill: The Greedy Pod

## Scenario

A Deployment named `bloated-app` was created in the `quota-land` namespace, but it struggles to deploy any pods. The namespace administrator has applied strict resource quotas.

## Task

1. Investigate why the `bloated-app` Deployment cannot scale up.
2. Modify the Deployment's resource requests to satisfy the namespaced ResourceQuota. Reducing the request to `200m` CPU should be sufficient for this lightweight app.
3. Verify the Pod starts successfully.

## Validation

Run `drill verify cluster/resource-quota-exceeded` to check your work.
