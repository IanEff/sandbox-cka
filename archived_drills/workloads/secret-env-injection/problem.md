# Drill: The Forgotten Secret

## Scenario

A Deployment named `web-app` has been pushed to the `secure-app` namespace. However, the pods are failing to start. The developer mentioned something about an API Key that needed to be configured but forgot to commit the security manifest.

## Task

1. Diagnose why the `web-app` pods are failing.
2. Create the missing Kubernetes resource required by the Deployment.
3. The key required by the application is `API_KEY`, and the value should be `12345-secret-token`.
4. Ensure the pods transition to a `Running` state.

## Validation

Run `drill verify workloads/secret-env-injection` to check your work.
