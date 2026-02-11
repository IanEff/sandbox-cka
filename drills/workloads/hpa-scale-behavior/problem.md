# Drill: HPA Scale Behavior

## Scenario

You are setting up an HPA for a critical `php-apache` application in namespace `hpa-behavior`.
Because of spiky traffic, the operations team wants to slow down the scale-down process to ensure capacity remains available for short lulls.

## Task

1. Create a Deployment named `php-apache` in Namespace `hpa-behavior`:
   - Image: `registry.k8s.io/hpa-example`
   - Requests: CPU `200m`
   - Port: `80`
   - Replicas: `1`
2. Expose the Deployment as a Service `php-apache` on port `80`.
3. Create a HorizontalPodAutoscaler `php-apache`:
   - Scale target: Deployment `php-apache`
   - Min replicas: `1`, Max replicas: `10`
   - Metric: CPU utilization `50%`
   - **Behavior**: Configure `scaleDown` stabilization window to `60` seconds.

## Hints

- You need HPA `v2` API.
- Use `spec.behavior.scaleDown.stabilizationWindowSeconds`.
- Ensure Metrics Server works (it is installed).
