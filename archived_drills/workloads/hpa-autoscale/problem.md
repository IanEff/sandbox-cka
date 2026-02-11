# HPA Autoscaling

A deployment `web-api` in namespace `autoscale-test` needs horizontal pod autoscaling configured.

The deployment currently runs with 1 replica.

**Your Task:**
Configure a HorizontalPodAutoscaler for `web-api` with:
- Minimum replicas: 2
- Maximum replicas: 10
- Target CPU utilization: 50%

**Constraints:**
- HPA must be named `web-api-hpa`.
- The deployment already has resource requests configured.
