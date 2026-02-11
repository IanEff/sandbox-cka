# Pod Security Context - User & Group

## Problem

Create a Pod named `secure-pod` in the `default` namespace using the image `busybox:1.28`.
This Pod should simply run the command `sleep 3600`.

Configure the Pod's Security Context so that:
- The container runs as User ID `1000`.
- The Pod uses fsGroup `2000`.

Once the Pod is running, execute a command inside it to retrieve the current user and group information (the output of `id`).
Write this output to `/opt/course/2/id.txt`.
