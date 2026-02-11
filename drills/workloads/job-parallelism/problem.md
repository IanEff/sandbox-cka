# Job with Parallelism

## Objective
Create a Job that runs multiple Pods in parallel to complete a set of tasks.

## Instructions
1.  Create a Job named `batch-processor` in the `default` namespace.
2.  Use the image `busybox` with the command `sleep 5`.
3.  The Job should require a total of **10 successful completions**.
4.  It should run **5 Pods in parallel**.

## Verification
The Job `batch-processor` should be created and eventually complete successfully with 10 succeeded pods.
