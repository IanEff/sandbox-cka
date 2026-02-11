# Drill: JSONPath Complex Query

## Scenario

There are several pods running in the namespace `jsonpath-drill`.

You need to:

1. List all Pods in the namespace `jsonpath-drill`.
2. Sort them by creation timestamp (oldest first).
3. Output **only** the Pod Name and the Node Name for each pod.
4. Write the output to `/opt/course/drill/jsonpath.txt` in the following format (tab or space separated header/rows):

```
POD          NODE
pod-a        node-1
pod-b        node-2
```

(The exact spacing width doesn't match, just the columns POD and NODE).

## Constraints

- Use `kubectl` with `-o custom-columns` or `-o jsonpath`.
- Namespace: `jsonpath-drill`
- Output file: `/opt/course/drill/jsonpath.txt`
