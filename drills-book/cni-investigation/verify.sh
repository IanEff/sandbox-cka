#!/bin/bash
DIR="/opt/course/overlay1"

if [ ! -f "$DIR/cni-info.txt" ]; then echo "Missing cni-info.txt"; exit 1; fi
if [ ! -f "$DIR/plugin-count.txt" ]; then echo "Missing plugin-count.txt"; exit 1; fi
if [ ! -f "$DIR/netns-path.txt" ]; then echo "Missing netns-path.txt"; exit 1; fi

# Check if pod running
kubectl get pod net-inspector --no-headers > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "Pod net-inspector not found"; exit 1; fi

# Optional check for content plausibility (non-empty)
if [ ! -s "$DIR/cni-info.txt" ]; then echo "cni-info.txt is empty"; exit 1; fi

exit 0
