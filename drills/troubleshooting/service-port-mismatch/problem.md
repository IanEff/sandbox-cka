# Drill: Port of Call

A developer deployed a simple Nginx app (`port-test`) and a service (`port-test-svc`).
They claim they can't reach the app via the service.

1. Create a temporary pod to test connectivity: `kubectl run curl --image=curlimages/curl --rm -it -- restart=Never -- curl http://port-test-svc`
2. Diagnose why it fails.
3. Fix the **Service** so that it correctly forwards traffic to the application's listening port.
