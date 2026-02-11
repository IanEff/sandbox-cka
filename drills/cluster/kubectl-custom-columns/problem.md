# Custom Columns Output

**Drill Goal:** Use `kubectl` formatting to create a custom report.

## Problem

Create a file named `/opt/course/12/pod_report.txt` (ensure directory exists or use local path `./pod_report.txt` if testing locally, but instructions say `/opt/course/12/`).
The file should contain a list of ALL Pods in the `kube-system` namespace.
Format the output using **custom columns** with the following headers and values:
*   `POD_NAME`: The name of the pod.
*   `NODE`: The name of the node it is running on.
*   `STATUS`: The status phase of the pod.

## Validation

Verify the file exists and contains the correct headers and data.
