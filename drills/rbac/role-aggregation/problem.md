# Drill: RBAC ClusterRole Aggregation

## Scenario

You want to create a "Super Reader" role `aggregate-reader` that automatically gains permissions whenever a new CRD or controller defines a "reader" role.

## Task

1. Create a `ClusterRole` named `aggregate-reader`.
2. It should **not** have any `rules` defined directly.
3. Instead, it must use `aggregationRule` to include rules from any ClusterRole that has the label:
   `rbac.example.com/aggregate-to-reader: "true"`

## Verification

There are already two ClusterRoles in the cluster (`cr-reader-1`, `cr-reader-2`) with this label.
If you set it up correctly, `aggregate-reader` will automatically inherit their rules.

## Hints

- `aggregationRule.clusterRoleSelectors`
