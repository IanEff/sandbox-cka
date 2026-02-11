# Horizontal Pod Autoscaling

Configure autoscaling for a PHP apache application based on CPU utilization.

Requirements:

- Create a deployment `php-apache` in namespace `scaling`
- Use image `registry.k8s.io/hpa-example`
- Configure resource requests for the container: CPU `200m`
- Expose the deployment as a Service `php-apache` (port 80)
- Create a HorizontalPodAutoscaler that:
  - Maintains between 1 and 10 replicas
  - Scales up when CPU utilization exceeds 50%
- (Optional) Verify it scales by generating load

Current state: Namespace `scaling` does not exist. Metrics server is running in the cluster.
