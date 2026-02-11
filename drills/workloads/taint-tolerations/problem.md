# Tainted Node Scheduling

A critical monitoring pod needs to run on a node that has been tainted to prevent regular workloads from being scheduled there.

The node `ubukubu-node01` (or one of the worker nodes) has been tainted with:

- Key: `monitoring`
- Value: `true`
- Effect: `NoSchedule`

Requirements:

- Create a pod named `monitor-agent` in the `monitoring` namespace
- The pod must use image `nginx:alpine`
- The pod must successfully schedule on the tainted node
- The pod must be in Running state

Current state: The taint is applied but no workload can currently schedule on the tainted node.
