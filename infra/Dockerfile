# syntax=docker/dockerfile:1

FROM registry:2 AS registry

FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-cacher-ng \
  ca-certificates \
  curl \
  dumb-init \
  squid \
  && rm -rf /var/lib/apt/lists/*

# registry binary (distribution)
COPY --from=registry /bin/registry /usr/local/bin/registry

# Config
COPY apt-cacher-ng/acng.conf /etc/apt-cacher-ng/acng.conf
COPY registry/ /etc/sandbox-cache/registry/
COPY squid/squid.conf /etc/squid/squid.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Data dirs (mounted as volumes in compose)
RUN mkdir -p /var/lib/sandbox-registry \
  && mkdir -p /var/cache/apt-cacher-ng \
  && mkdir -p /var/spool/squid \
  && mkdir -p /var/log/squid \
  && chown -R apt-cacher-ng:apt-cacher-ng /var/cache/apt-cacher-ng \
  && chown -R proxy:proxy /var/spool/squid /var/log/squid

EXPOSE 3142 3128 5001 5002 5003 5004

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]
