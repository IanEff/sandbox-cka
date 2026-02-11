# Drill: DaemonSet Control Plane Toleration

## Scenario

You need to deploy a monitoring agent on **every** node in the cluster, including the control plane node which usually rejects workloads.

1. Create a DaemonSet named `monitor-agent` in the `default` namespace using image `busybox:1.36`.
2. The pods should run the command `sleep 3600`.
3. Add the necessary **toleration** to the Pod template so that it schedules on the control plane node (which has taint `node-role.kubernetes.io/control-plane:NoSchedule`).

## Constraints

- Resource Name: `monitor-agent`
- Type: DaemonSet
- Must run on Control Plane.
