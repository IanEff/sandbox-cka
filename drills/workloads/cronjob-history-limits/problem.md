# CronJob History Limits

Create a CronJob named `cleanup` in the `default` namespace.
- Image: `busybox`
- Schedule: `*/1 * * * *` (Every minute)
- Command: `echo cleanup`
- Successful Jobs History Limit: `2`
- Failed Jobs History Limit: `1`
