# PodDisruptionBudget and Node Drain

Namespace `project-lima` contains a Deployment named `payment-api` with 3 replicas spread across cluster nodes.

The operations team needs to perform maintenance on a worker node. The `payment-api` service is business-critical and **must maintain at least 2 pods running** at all times during voluntary disruptions (drains, upgrades, etc.).

Your tasks:

1. Create a PodDisruptionBudget named `payment-api-pdb` in namespace `project-lima`
2. It must target the pods belonging to the `payment-api` Deployment
3. It must guarantee a minimum of **2** pods are available at any time
4. Write the number of currently **allowed disruptions** (from PDB status) into `/home/vagrant/pdb-allowed-disruptions.txt`

## Information

- Use `kubectl get pdb` to inspect PodDisruptionBudget status
- A PDB uses the same label selectors as Services to identify target pods
- `minAvailable` and `maxUnavailable` are two ways to express the same constraint
- With 3 replicas and minAvailable=2, only 1 disruption is allowed at a time


## Validation

Verify the PDB allows correct disruptions:
```bash
kubectl get pdb payment-api-pdb -n project-lima
# Should show Allowed Disruptions: 1
```
Verify your record file:
```bash
cat /home/vagrant/pdb-allowed-disruptions.txt
```
