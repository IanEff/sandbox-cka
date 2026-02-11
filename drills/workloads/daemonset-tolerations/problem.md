# DaemonSet Tolerations

## Problem

A DaemonSet named `monitoring-agent` is running in the `default` namespace.
However, it is not running on the Control Plane node because of a taint.

1.  Identify the taint on the control plane node (usually `node-role.kubernetes.io/control-plane:NoSchedule`).
2.  Update the DaemonSet to tolerate this taint so that it schedules a pod on the control plane node as well.
3.  Once the DaemonSet has pods running on ALL nodes (including control plane), count the total number of pods for this DaemonSet.
4.  Write this count to `/opt/course/3/count.txt`.
