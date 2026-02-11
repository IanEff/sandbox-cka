# Drill: Headless Service DNS

## Scenario

You need to deploy a stateful application `goku` where each pod needs to be directly addressable via DNS.
Namespace: `headless`.

## Task

1. Create a Deployment named `goku` with 2 replicas of `nginx:alpine` in namespace `headless`. Label it `app=goku`.
2. Create a **Headless Service** named `goku` that exposes port 80 and selects the deployment.
   - It MUST NOT have a ClusterIP allocated.

## Verification

You should be able to resolve individual pod IPs via DNS lookup of `goku.headless.svc.cluster.local`.

## Hints

- `clusterIP: None`
