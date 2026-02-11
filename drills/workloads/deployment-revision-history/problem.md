# Drill: Deployment Revision History

## Scenario

Your cluster is running out of etcd storage space because deployments are keeping too many old ReplicaSets.
You need to enforce a stricter limit on the revision history for a new application.
Namespace: `history-limit`.

## Task

1. Create a Deployment named `clean-history` in Namespace `history-limit`.
   - Image: `nginx:alpine`
   - Replicas: `1`
2. Configure the Deployment to keep **maximum 2** old ReplicaSets (revisions) for rollback purposes.
   (The default is usually 10).

## Hints

- `spec.revisionHistoryLimit`
