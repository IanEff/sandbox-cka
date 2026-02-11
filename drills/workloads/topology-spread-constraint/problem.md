# Topology Spread Constraint

## Problem

A Deployment named `spread-deploy` has been created in the `default` Namespace.

Update this Deployment so that its Pods are distributed evenly across nodes based on the `kubernetes.io/hostname` topology key.

The constraint should:
1.  Have a `maxSkew` of 1.
2.  Use the `DoNotSchedule` `whenUnsatisfiable` policy.
3.  Match the existing label selector of the pods (`app=spread-app`).

Ensure the deployment successfully scales to 4 replicas and they are scheduled appropriately.
