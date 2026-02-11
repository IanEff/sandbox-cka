# Broken Service Selector

The Service `broken-svc` is supposed to load balance traffic to the `backend-pod`, but it has no endpoints.

1. Fix the configuration so that `broken-svc` correctly targets `backend-pod`.
2. Do not delete the Pod. Modify the Service.
