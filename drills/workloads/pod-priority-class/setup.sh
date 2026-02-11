#!/bin/bash
kubectl delete priorityclass mission-critical --ignore-not-found
kubectl delete pod critical-pod --ignore-not-found
