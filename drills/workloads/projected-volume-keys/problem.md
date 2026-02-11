# Drill: Projected Volume Keys

## Problem

In the namespace `projection-lab`:

1. Create a ConfigMap `nginx-custom` with two Data items:
   - `nginx.conf`: "server { listen 80; }"
   - `virtualhost.conf`: "server_name example.com;"
2. Create a Pod `web-server` with image `nginx:alpine`.
3. Mount the ConfigMap to `/etc/nginx/conf.d`.
4. **Crucial Requirement**: Configure the volume mount so that **ONLY** the `virtualhost.conf` key is projected into the file `my-site.conf` within that directory. The `nginx.conf` key should **NOT** appear in the directory.

## Hints

- `items` array in the `configMap` volume source.
- `key` (source) and `path` (destination filename) properties.
