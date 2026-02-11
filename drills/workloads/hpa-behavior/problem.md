# Drill: HPA Scale Behavior

## Scenario

A deployment named `hpa-behavior-deploy` is running in the `default` namespace. It is critical that this application does not scale down too quickly during traffic dips.

## Task

Create a HorizontalPodAutoscaler named `hpa-behavior-deploy` for this deployment with the following requirements:

1. **Metric**: Average CPU utilization of 50%.
2. **Min/Max**: Min 1, Max 10 pods.
3. **Scale Down Behavior**:
    - Stabilization window: 60 seconds.
    - Policy: Scale down at most 1 pod every 60 seconds (optional, but ensure stabilization is set).

## Context

Use Kubernetes HPA v2 (`autoscaling/v2`).
