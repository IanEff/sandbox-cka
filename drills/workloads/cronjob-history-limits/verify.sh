#!/bin/bash
SUCCESS=$(kubectl get cronjob cleanup -o jsonpath='{.spec.successfulJobsHistoryLimit}')
FAILED=$(kubectl get cronjob cleanup -o jsonpath='{.spec.failedJobsHistoryLimit}')

if [[ "$SUCCESS" != "2" ]]; then echo "Wrong successful limit"; exit 1; fi
if [[ "$FAILED" != "1" ]]; then echo "Wrong failed limit"; exit 1; fi
