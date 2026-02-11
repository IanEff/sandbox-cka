# Troubleshooting: Identify Pods Terminated First Under Pressure

The cluster is experiencing memory pressure. Management needs to know which pods would be evicted first.

In namespace `project-omega`, several pods are running with different QoS classes.

Your tasks:

1. Examine all pods in namespace `project-omega`
2. Identify which pods have `BestEffort` QoS class (these are terminated first under resource pressure)
3. Write the names of pods with `BestEffort` QoS to `/home/vagrant/pods-terminated-first.txt`, one per line, sorted alphabetically

## Information

- Kubernetes evicts pods in this order: BestEffort → Burstable → Guaranteed
- QoS is determined by resource requests/limits configuration
- Use `kubectl describe pod` or `-o jsonpath` to find the qosClass

**Hint**: `kubectl get pod <name> -o jsonpath='{.status.qosClass}'`
