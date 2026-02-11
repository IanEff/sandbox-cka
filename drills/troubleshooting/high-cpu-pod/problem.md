# Drill: High CPU Pod Troubleshooting

## Problem

In the namespace `cpu-burn`, there are 3 pods running.
One of them is consuming significantly more CPU than the others.

1. Identify the high-CPU pod.
2. Write the name of the pod to `/home/vagrant/high-cpu-pod.txt` (or appropriate home dir).

## Hints

- `kubectl top pods` (Metrics server is active!)
