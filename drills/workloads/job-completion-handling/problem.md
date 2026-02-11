# Job Completion Handling

**Drill Goal:** Configure a Job with specific completion and lifecycle parameters.

## Problem

Create a Job named `batch-processor` in the namespace `job-specialist`.
The Job should have the following characteristics:
*   Use the image `busybox` or `busybox:1.28`.
*   Execute the command `sleep 5`.
*   Successfully complete **5** times.
*   Run **2** pods in parallel.
*   Automatically be deleted **30 seconds** after it finishes.

## Validation

Verify that the Job is created with the correct specifications and that the pods are running/completed as expected.
