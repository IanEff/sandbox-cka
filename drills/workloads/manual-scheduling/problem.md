# Manual Scheduling

The Kubernetes Scheduler has crashed (or been stopped for maintenance), but you need to deploy a critical pod immediately.

1. Identify that the scheduler is not running (the setup script has stopped it!).
2. The Pod `crisis-aversion` has been created but is stuck in `Pending`.
3. Manually schedule the pod to node `ubukubu-node-1` without starting the scheduler.
    * Hint: You may need to edit the running pod definition (which is hard for `nodeName`) or recreate it with the `nodeName` field set.
4. Once the pod is running, restart the `kube-scheduler` to restore cluster health.
