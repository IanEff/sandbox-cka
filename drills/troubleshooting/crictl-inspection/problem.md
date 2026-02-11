# Drill: crictl Inspection

## Question

**Context:**
A Pod named `lost-log` is running in the Namespace `trouble`.
You need to perform low-level container inspection on the node where the Pod is running.

**Task:**

1. Identify the node running the `lost-log` Pod.
2. SSH into that node (or use `crictl` if you are on the control plane and it allows scheduling).
3. Use `crictl` to find the **Process ID (PID)** of the main container process for this Pod.
4. Annotate the Pod `lost-log` in Namespace `trouble` with the key `mystery/pid` and the value you found.
    * Example: `kubectl annotate pod lost-log -n trouble mystery/pid=12345`

## Hints

* `crictl ps` / `crictl pods`
* `crictl inspect <ID>`
* Look for `.info.pid` inside the inspection JSON.
