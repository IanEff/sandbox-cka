# Run As User Security

Create a Pod named `secure-pod` element using image `busybox` and command `sleep 3600`.
The Pod must use a SecurityContext to:
- Run with User ID `1001`
- Run with Group ID `3000`

Ensure these settings apply to the container `secure-container`.
