# Drill: HPA Missing Metrics

## Problem

In the namespace `hpa-test`, a Deployment `php-apache` and a HorizontalPodAutoscaler `php-apache` have been created.
However, if you check `kubectl get hpa -n hpa-test`, the TARGETS column shows `<unknown>/50%`.
The autoscaler is not working because metrics cannot be calculated.

1. Fix the issue so that HPA can calculate the replica count. (Hint: something is missing in the Pod Spec).
2. Ensure the HPA is reporting a percentage (e.g. `0%/50%` or similar).

## Hints

- HPA requires *resource requests* to be defined on containers to calculate cpu utilization percentage.
