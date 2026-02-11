#!/bin/sh
set -eu

APT_PORT="${SANDBOX_CACHE_APT_PORT:-3142}"
SQUID_PORT="${SANDBOX_CACHE_SQUID_PORT:-3128}"
ENABLE_SQUID="${SANDBOX_CACHE_ENABLE_SQUID:-0}"
REGISTRY_LOG_LEVEL="${SANDBOX_CACHE_REGISTRY_LOG_LEVEL:-info}"

DOCKERHUB_PORT="${SANDBOX_CACHE_REGISTRY_DOCKERHUB_PORT:-5001}"
K8S_PORT="${SANDBOX_CACHE_REGISTRY_K8S_PORT:-5002}"
GHCR_PORT="${SANDBOX_CACHE_REGISTRY_GHCR_PORT:-5003}"
QUAY_PORT="${SANDBOX_CACHE_REGISTRY_QUAY_PORT:-5004}"

# Ensure squid dirs are initialized (squid is picky)
if [ "$ENABLE_SQUID" = "1" ]; then
  if [ ! -d /var/spool/squid/00 ]; then
    squid -z >/dev/null 2>&1 || true
  fi
fi

# Run apt-cacher-ng in foreground (logs to stdout)
# Debian's apt-cacher-ng uses ForeGround=1 (not a -f flag).
/usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng ForeGround=1 Port="$APT_PORT" &
P1=$!

echo "[cache] apt-cacher-ng listening on :${APT_PORT}"

echo "[cache] registry proxy 'dockerhub' listening on :${DOCKERHUB_PORT}"
REGISTRY_LOG_LEVEL="$REGISTRY_LOG_LEVEL" /usr/local/bin/registry serve /etc/sandbox-cache/registry/dockerhub.yml &
P2=$!

echo "[cache] registry proxy 'k8s' listening on :${K8S_PORT}"
REGISTRY_LOG_LEVEL="$REGISTRY_LOG_LEVEL" /usr/local/bin/registry serve /etc/sandbox-cache/registry/k8s.yml &
P3=$!

echo "[cache] registry proxy 'ghcr' listening on :${GHCR_PORT}"
REGISTRY_LOG_LEVEL="$REGISTRY_LOG_LEVEL" /usr/local/bin/registry serve /etc/sandbox-cache/registry/ghcr.yml &
P4=$!

echo "[cache] registry proxy 'quay' listening on :${QUAY_PORT}"
REGISTRY_LOG_LEVEL="$REGISTRY_LOG_LEVEL" /usr/local/bin/registry serve /etc/sandbox-cache/registry/quay.yml &
P5=$!

if [ "$ENABLE_SQUID" = "1" ]; then
  echo "[cache] squid listening on :${SQUID_PORT}"
  # Clean up stale PID file if it exists (prevents crash on fast restart)
  rm -f /run/squid.pid
  # squid defaults to daemonizing; use -N for foreground
  squid -N -f /etc/squid/squid.conf &
  P6=$!
fi

# Propagate signals and exit when any child exits
trap 'kill -TERM $P1 $P2 $P3 $P4 $P5 ${P6:-} 2>/dev/null || true; wait' INT TERM

# dash (/bin/sh on Debian) doesn't support `wait -n`.
# Keep the container alive while all children are alive; exit non-zero if any dies.
PIDS="$P1 $P2 $P3 $P4 $P5"
if [ -n "${P6:-}" ]; then
  PIDS="$PIDS $P6"
fi

while true; do
  for pid in $PIDS; do
    if ! kill -0 "$pid" 2>/dev/null; then
      echo "[cache] process $pid exited; shutting down"
      exit 1
    fi
  done
  sleep 2
done
