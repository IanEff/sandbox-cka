# Multi-Container Pod: Log Investigation

In namespace `debug-lab`, a Pod named `data-pipeline` runs three containers working together:

- `fetcher` - downloads data
- `processor` - processes data
- `exporter` - exports results

One of the containers is failing (CrashLoopBackOff). The other two are running fine.

Your tasks:

1. Identify which container is crashing and write its name to `/home/vagrant/failing-container.txt`

2. Check the logs of the failing container (use `--previous` if the current instance has no logs yet) and write the **error message** (the last line of output) to `/home/vagrant/crash-error.txt`

3. Fix the failing container so the Pod reaches **Running** status with all 3 containers ready (**3/3**). The pod must still be named `data-pipeline` and still have all three containers (`fetcher`, `processor`, `exporter`).

## Information

- Use `kubectl logs <pod> -c <container>` to view a specific container's logs
- Use `--previous` flag to see logs from a crashed container's previous instance
- Use `kubectl describe pod` to see container statuses, restart counts, and exit codes
- Pods are immutable - to fix the container, delete and recreate the pod with corrected spec


## Validation

Verify the pod is fully running (3/3):
```bash
kubectl get pod data-pipeline -n debug-lab
```
Verify your investigation files:
```bash
cat /home/vagrant/failing-container.txt
cat /home/vagrant/crash-error.txt
```
