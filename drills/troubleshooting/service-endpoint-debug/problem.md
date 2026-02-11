# Service Endpoint Troubleshooting

A Deployment `frontend-dep` and a Service `frontend-svc` have been created in namespace `troubleshooting-5`.
However, the Service has no endpoints, and users cannot connect.

Fix the configuration so that `frontend-svc` correctly routes traffic to the `frontend-dep` Pods.
Do not delete the Service or Deployment; update them in place.
