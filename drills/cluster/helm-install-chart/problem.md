# Drill: Helm Install Chart

## Question

**Context:**
A local Helm chart is available at `./mychart` (in the project root).
The Namespace `neon-city` needs to be created.

**Task:**

1. Create the Namespace `neon-city`.
2. Install the local chart `./mychart` into the `neon-city` namespace.
    * The Helm Release name must be `neon-gateway`.
    * Override the default `replicaCount` to be `2`.

## Hints

* `helm install RELEASE CHART [flags]`
* `--set` or values file.
