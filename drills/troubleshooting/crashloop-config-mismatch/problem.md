# CrashLoop Config Mismatch

## Scenario

The Deployment `broken-app` in namespace `trouble` has a pod in CrashLoopBackOff state.
The application requires a configuration value provided by an environment variable `DB_URL` which is expected to be loaded from a ConfigMap.

## Requirements

- **Namespace**: `trouble`
- **Deployment**: `broken-app`
- **Task**: Identify the missing configuration and fix it.
  - The Pod consumes environment variables from ConfigMap `app-config` using `envFrom`.
  - The application crashes if `DB_URL` is missing.
  - You must update the ConfigMap `app-config` to include `DB_URL=postgres://db:5432`.
  - Ensure the Pod is running and stable.

## Verification

The drill verifies that the Pod is Running and the ConfigMap has the correct key.
