# Drill: Env From Aggregation

## Question

**Context:**
In the namespace `env-mix`, there exists:

* A ConfigMap named `app-settings` containing `COLOR=blue`.
* A Secret named `app-secrets` containing `API_KEY=secret123`.

**Task:**
Create a Pod named `aggregator` in the namespace `env-mix`.

* Image: `alpine`
* Command: `sh`, `-c`, `env; sleep 3600`
* **Environment Configuration:**
    1. Load **all** key/value pairs from the Secret `app-secrets` directly as environment variables.
    2. Load **all** key/value pairs from the ConfigMap `app-settings` as environment variables.
        * **Requirement:** These keys must be prefixed with `CONF_`. (e.g., `COLOR` becomes `CONF_COLOR`).

## Hints

* `envFrom`
* `prefix`
* `configMapRef` / `secretRef`
