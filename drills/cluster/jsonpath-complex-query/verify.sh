#!/bin/bash
# Verify JSONPath Drill
set -e

FILE="/opt/course/drill/jsonpath.txt"

if [ ! -f "$FILE" ]; then
    echo "FAIL: File $FILE does not exist."
    exit 1
fi

echo "File content:"
cat "$FILE"

# Check for Header
if ! grep -q "POD" "$FILE" || ! grep -q "NODE" "$FILE"; then
    echo "FAIL: Header POD/NODE missing."
    exit 1
fi

# Check order: pod-early must appear before pod-late
EARLY_LINE=$(grep -n "pod-early" "$FILE" | cut -d: -f1)
LATE_LINE=$(grep -n "pod-late" "$FILE" | cut -d: -f1)

if [ -z "$EARLY_LINE" ] || [ -z "$LATE_LINE" ]; then
    echo "FAIL: Pod names not found in file."
    exit 1
fi

if [ "$EARLY_LINE" -gt "$LATE_LINE" ]; then
    echo "FAIL: Sorting incorrect. 'pod-early' should trigger before 'pod-late'."
    exit 1
fi

# Check if Node name is present (simple check for any text in second column)
# Assume format "name   node"
if ! awk 'NR>1 {if ($2 == "") exit 1}' "$FILE"; then
    echo "FAIL: Second column (NODE) seems empty."
    exit 1
fi

echo "SUCCESS: File format and sorting correct."
