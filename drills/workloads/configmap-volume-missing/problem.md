# Drill: Missing in Action

The pod `broken-config` is failing with a configuration error. `kubectl get pod broken-config` shows `ContainerConfigError` or similar.

1. Diagnose **why** it is failing.
2. Fix it by creating the missing resource. The ConfigMap should contain a key `game.properties` with value `enemies=aliens`.
3. Ensure the Pod starts (it might auto-retry, or you might need to recreate it if it gave up).
