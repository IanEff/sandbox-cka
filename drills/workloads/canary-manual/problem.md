# Drill: Manual Canary Rollout

## Scenario

You are testing a new version of your application using a manual canary deployment strategy.
You have a namespace `canary-ops` with an existing stable Deployment `main-deploy` (v1) and a Service `app-svc`.

## Task

1. Inspect the existing Service `app-svc` to understand its selector.
2. Create a new Deployment named `canary-deploy`:
   - Image: `nginx:1.27-alpine`
   - It must receive traffic from the *same* Service `app-svc`.
3. Scale both `main-deploy` and `canary-deploy` such that:
   - The total number of pods serving traffic is **10**.
   - The canary version (`canary-deploy`) receives approximately **20%** of the traffic.

## Hints

- Services route traffic to any Pod matching the selector.
- Traffic distribution is roughly proportional to the number of replicas.
