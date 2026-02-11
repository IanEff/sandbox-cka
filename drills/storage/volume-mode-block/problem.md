# Drill: Block Volume Mode

## Problem

1.  Create a **Namespace** named `block-world`.
2.  Create a **PersistentVolume** named `block-pv` with the following requirements:
    *   Capacity: `100Mi`
    *   Access Modes: `ReadWriteOnce`
    *   Volume Mode: `Block`
    *   Storage Class: `manual-block`
    *   Host Path: `/var/tmp/blockfile` (This file has been created for you)
3.  Create a **PersistentVolumeClaim** named `block-pvc` in the namespace `block-world` that requests the `block-pv`.
4.  Create a **Pod** named `block-pod` in the namespace `block-world` with:
    *   Image: `busybox`
    *   Command: `sleep 3600`
    *   Volume: Mount the `block-pvc` as a **raw block device** at device path `/dev/xvda`.

## Reference

*   <https://kubernetes.io/docs/concepts/storage/persistent-volumes/#volume-mode>
