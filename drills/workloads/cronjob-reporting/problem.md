# CronJob Reporting

In namespace `reports`:

1. Create a CronJob named `disk-checker`.
2. Schedule: Every 1 minute (`*/1 * * * *`).
3. Image: `busybox`.
4. Command: `df -h`.
5. The job should keep exactly **5** successful completions in history (`successfulJobsHistoryLimit`).
6. The job should keep **2** failed completions (`failedJobsHistoryLimit`).

Manually trigger a Job from this CronJob named `manual-test` to verify it works immediately.
