#!/bin/bash
DIR="/opt/course/overlay2"

if [ ! -f "$DIR/pod-ips.txt" ]; then echo "Missing pod-ips.txt"; exit 1; fi
if [ ! -f "$DIR/ping-result.txt" ]; then echo "Missing ping-result.txt"; exit 1; fi
if [ ! -f "$DIR/route-to-receiver.txt" ]; then echo "Missing route-to-receiver.txt"; exit 1; fi
if [ ! -f "$DIR/tcpdump-cmd.sh" ]; then echo "Missing tcpdump-cmd.sh"; exit 1; fi

# Check pods
kubectl get pod sender -n net-lab > /dev/null 2>&1 || { echo "Pod sender missing"; exit 1; }
kubectl get pod receiver -n net-lab > /dev/null 2>&1 || { echo "Pod receiver missing"; exit 1; }

exit 0
