#!/bin/bash
# Verify for kubectl-custom-columns

FILE="/opt/course/12/pod_report.txt"

if [ ! -f "$FILE" ]; then
    echo "FAIL: File $FILE does not exist."
    exit 1
fi

# Check Headers
HEAD=$(head -n 1 $FILE)
# Whitespace might vary, so check for presence of words
if [[ "$HEAD" != *"POD_NAME"* ]] || [[ "$HEAD" != *"NODE"* ]] || [[ "$HEAD" != *"STATUS"* ]]; then
    echo "FAIL: Headers incorrect. Found: '$HEAD'"
    exit 1
fi

# Check Content (Sampling)
# Ensure at least one known pod is there, e.g., kube-proxy or coredns
if ! grep -q "coredns" $FILE && ! grep -q "kube-proxy" $FILE; then
    echo "FAIL: File usage doesn't seem to list kube-system pods."
    exit 1
fi

echo "SUCCESS: Custom columns report generated."
