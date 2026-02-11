# Event and Log Forensics

The operations team needs you to demonstrate mastery of cluster events and Pod lifecycle investigation.

Your tasks:

1. Write a kubectl command into `/home/vagrant/cluster-events.sh` that displays events from **all namespaces**, sorted by creation time (`metadata.creationTimestamp`). The script should be executable and produce output when run.

2. In namespace `forensics-lab`, there is a Deployment `web-app` with 2 replicas. Perform these steps:
   - Delete one of the `web-app` Pods manually
   - Wait for the replacement Pod to be running
   - Capture the events from namespace `forensics-lab` into `/home/vagrant/pod-lifecycle-events.log`

3. Write the **restart policy** of pods managed by the `web-app` Deployment into `/home/vagrant/restart-policy.txt` (just the value, e.g., `Always`, `OnFailure`, or `Never`)

## Information

- `kubectl get events` supports `--sort-by` for field-based sorting
- Events capture scheduling, image pulling, container creation, and start events
- The restart policy for Deployment-managed pods has a specific default
- Use `-A` or `--all-namespaces` for cluster-wide queries


## Validation

Verify your script output:
```bash
bash /home/vagrant/cluster-events.sh | head
```
Verify the captured logs and restart policy:
```bash
cat /home/vagrant/pod-lifecycle-events.log
cat /home/vagrant/restart-policy.txt
```
