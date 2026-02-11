#!/bin/bash
DIR="/opt/course/overlay7"

if [ ! -f "$DIR/use-case.txt" ]; then echo "Missing use-case.txt"; exit 1; fi
# Weak check if multus missing
if [ -f "$DIR/nad.yaml" ]; then echo "NAD yaml found"; fi

exit 0
