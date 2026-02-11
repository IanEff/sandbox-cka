# Fix ConfigMap Crash

In namespace `trouble-cm`:

1. A Pod named `app-pod` is failing to start (`CreateContainerConfigError` or `CrashLoopBackOff`).
2. Identify the issue (it's referencing a missing key in a ConfigMap).
3. The ConfigMap `app-config` exists, but the key `db-url` is missing.
4. Update the ConfigMap to add `db-url="postgres://localhost:5432"`.
5. Ensure the Pod restarts and enters `Running` state.
