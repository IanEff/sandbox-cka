# Multi-Network Pod Configuration

Your cluster uses Multus for multi-network support. A database team needs Pods with isolated storage network interfaces.

(Note: If your environment does not have Multus CNI installed, you may not be able to apply the `NetworkAttachmentDefinition`. In that case, create the manifest file but skip the `kubectl apply` and Pod creation steps, and document the limitation in `use-case.txt`. The verification script will check for the file.)

1. Examine the existing `NetworkAttachmentDefinition` resources and write their names to `/opt/course/overlay7/network-attachments.txt` (If none, write "None").
2. Create a `NetworkAttachmentDefinition` named `storage-net` in Namespace `database` with:
    * Type: `macvlan`
    * Mode: `bridge`
    * Subnet: `10.200.0.0/24`
    * Range: `10.200.0.100` to `10.200.0.200`
    * (Save the YAML to `/opt/course/overlay7/nad.yaml` even if you can't apply it).
3. Create two Pods in Namespace `database` on the SAME node:
    * `db-primary` with image `postgres:13-alpine`, annotation to use `storage-net`
    * `db-replica` with image `postgres:13-alpine`, annotation to use `storage-net`
4. Verify both Pods have the additional `net1` interface by exec'ing into each and running `ip addr`.
    * Write the `net1` IP addresses to `/opt/course/overlay7/storage-ips.txt`
5. From `db-primary`, ping `db-replica`'s `net1` IP and write the result to `/opt/course/overlay7/storage-network-test.txt`
6. Write an explanation in `/opt/course/overlay7/use-case.txt`: Why would you use a separate storage network? (2-3 sentences)

**Verification**: Both Pods should have two network interfaces (if Multus present). We check for the created files and resources.
