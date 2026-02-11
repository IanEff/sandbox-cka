# Pod Stuck Terminating

There is a Pod named `cant-stop` in the `default` namespace that is stuck in a `Terminating` state because of a finalizer that will never be removed.
Force delete this Pod so it is no longer present in the cluster.
