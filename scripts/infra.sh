#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/infra/compose.yaml"


usage() {
  cat <<'EOF'
Usage: scripts/infra.sh <command>

Commands:
  up              Build + start the infrastructure (Cache + LB)
  down            Stop the infrastructure
  logs            Tail logs (Ctrl-C to stop)
  status          Show container status
  verify-cache    Check cache reachability + hit stats
  configure-trust Configure registry trust on running VMs
EOF
}

cmd="${1:-}"
if [[ -z "$cmd" ]]; then
  usage
  exit 2
fi

# OrbStack provides docker/docker-compose CLI compatibility
COMPOSE_CMD="docker compose"

configure_registry_trust() {
    # Only attempt if inside the project root where Vagrantfile exists or we can find it
    if [[ ! -f "$ROOT_DIR/Vagrantfile" ]]; then
        return 0
    fi

    if ! command -v vagrant &> /dev/null; then
        return 0
    fi

    echo "[INFRA] Checking for running cluster nodes to configure registry trust..."
    
    # Get list of running nodes
    local NODES
    NODES=$(cd "$ROOT_DIR" && vagrant status 2>/dev/null | grep "running" | awk '{print $1}' || true)

    if [[ -z "$NODES" ]]; then
        echo "[INFRA] No running cluster nodes found. Trust configuration will happen during bad 'vagrant up' via common.sh."
        return 0
    fi
    
    local HOST_IP="192.168.56.1"
    local REGISTRY_PORT="5050"
    local REGISTRY_URL="${HOST_IP}:${REGISTRY_PORT}"
    
    for node in $NODES; do
        echo "  -> Checking $node..."
        # Using vagrant ssh to run the patch
        # We use 'grep -q' to silently check. If not found, we append and restart.
        (cd "$ROOT_DIR" && vagrant ssh "$node" -c "
            set -e
            CONFIG_FILE='/etc/containerd/config.toml'
            TARGET_URL='${REGISTRY_URL}'
            
            if grep -q \"\$TARGET_URL\" \"\$CONFIG_FILE\"; then
                # Already configured
                exit 0
            fi
            
            echo \"     Patching containerd config...\"
            sudo bash -c \"cat <<TOML >> \$CONFIG_FILE

[plugins.\\\"io.containerd.grpc.v1.cri\\\".registry.mirrors.\\\"\$TARGET_URL\\\"]
  endpoint = [\\\"http://\$TARGET_URL\\\"]
TOML\"
            sudo systemctl restart containerd
        ") || echo "     [WARN] Failed to configure $node"
    done
}

case "$cmd" in
  up)
    # Ensure artifacts directory exists for local caching
    mkdir -p "$ROOT_DIR/infra/artifacts"
    
    $COMPOSE_CMD -f "$COMPOSE_FILE" up -d --build

    # OrbStack exposes 0.0.0.0-bound ports on all host interfaces,
    # so VMs can reach services at 192.168.56.1 directly (no bridge needed).

    configure_registry_trust
    echo "[INFRA] Registry available at localhost:5050 (Host) / 192.168.56.1:5050 (Cluster)"
    ;;
  down)
    $COMPOSE_CMD -f "$COMPOSE_FILE" down
    ;;
  logs)
    $COMPOSE_CMD -f "$COMPOSE_FILE" logs -f --tail=200
    ;;
  status)
    $COMPOSE_CMD -f "$COMPOSE_FILE" ps
    ;;
  configure-trust)
    configure_registry_trust
    ;;
  verify-cache)
    HOST_IP="192.168.56.1"
    echo "=== Cache Verification ==="
    echo ""

    # --- Port reachability from host ---
    echo "--- Port Reachability (from host) ---"
    PORTS="3142:APT 5001:DockerHub 5002:K8s 5003:GHCR 5004:Quay 3128:Squid 5050:Registry"
    ALL_OK=true
    for entry in $PORTS; do
      port="${entry%%:*}"
      label="${entry#*:}"
      printf "  %-12s localhost:%-5s " "$label" "$port"
      if timeout 1 bash -c "</dev/tcp/127.0.0.1/$port" 2>/dev/null; then
        printf "✅  "
      else
        printf "❌  "
        ALL_OK=false
      fi
      printf "${HOST_IP}:%-5s " "$port"
      if timeout 1 bash -c "</dev/tcp/$HOST_IP/$port" 2>/dev/null; then
        echo "✅"
      else
        echo "❌"
        ALL_OK=false
      fi
    done
    echo ""

    if ! $ALL_OK; then
      echo "[WARN] Some ports not reachable. Is 'scripts/infra.sh up' running?"
      echo ""
    fi

    # --- APT cache stats ---
    echo "--- APT Cache Stats (apt-cacher-ng) ---"
    APT_STATS=$(curl -sf "http://localhost:3142/acng-report.html?doCount=1" 2>/dev/null || true)
    if [[ -n "$APT_STATS" ]]; then
      # Extract key metrics from the HTML report
      TOTAL_DATA=$(echo "$APT_STATS" | grep -oP 'Transferred data.*?<td[^>]*>\K[^<]+' | head -1 || true)
      HIT_DATA=$(echo "$APT_STATS" | grep -oP 'direct cache hits.*?<td[^>]*>\K[^<]+' | head -1 || true)
      if [[ -n "$TOTAL_DATA" ]] || [[ -n "$HIT_DATA" ]]; then
        echo "  Transferred: ${TOTAL_DATA:-n/a}"
        echo "  Cache hits:  ${HIT_DATA:-n/a}"
      else
        echo "  apt-cacher-ng is running (detailed stats at http://localhost:3142/acng-report.html)"
      fi
    else
      echo "  [WARN] Could not reach apt-cacher-ng stats endpoint."
    fi
    echo ""

    # --- Registry mirror liveness ---
    echo "--- Registry Mirror Liveness ---"
    for entry in 5001:DockerHub 5002:K8s 5003:GHCR 5004:Quay; do
      port="${entry%%:*}"
      label="${entry#*:}"
      printf "  %-12s /v2/ -> " "$label"
      HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" "http://localhost:$port/v2/" 2>/dev/null || echo "000")
      if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "401" ]]; then
        echo "✅ (HTTP $HTTP_CODE)"
      else
        echo "❌ (HTTP $HTTP_CODE)"
      fi
    done

    # Local push registry
    printf "  %-12s /v2/ -> " "Registry"
    HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" "http://localhost:5050/v2/" 2>/dev/null || echo "000")
    if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "401" ]]; then
      echo "✅ (HTTP $HTTP_CODE)"
    else
      echo "❌ (HTTP $HTTP_CODE)"
    fi
    echo ""

    # --- Registry catalog (shows what's been cached) ---
    echo "--- Cached Images (registry catalogs) ---"
    for entry in 5001:DockerHub 5002:K8s 5003:GHCR 5004:Quay; do
      port="${entry%%:*}"
      label="${entry#*:}"
      CATALOG=$(curl -sf "http://localhost:$port/v2/_catalog" 2>/dev/null || echo '{}')
      REPOS=$(echo "$CATALOG" | grep -oP '"repositories":\[\K[^]]*' || true)
      if [[ -n "$REPOS" ]]; then
        COUNT=$(echo "$REPOS" | tr ',' '\n' | wc -l | tr -d ' ')
        echo "  $label ($COUNT cached): $(echo "$REPOS" | tr '"' ' ' | head -c 120)"
      else
        echo "  $label: (empty — no images cached yet)"
      fi
    done
    echo ""

    # --- VM-side check (if cluster nodes are running) ---
    if [[ -f "$ROOT_DIR/Vagrantfile" ]] && command -v vagrant &>/dev/null; then
      NODES=$(cd "$ROOT_DIR" && vagrant status 2>/dev/null | grep "running" | awk '{print $1}' || true)
      if [[ -n "$NODES" ]]; then
        echo "--- VM-Side Reachability ---"
        FIRST_NODE=$(echo "$NODES" | head -1)
        echo "  Testing from $FIRST_NODE -> $HOST_IP ..."
        (cd "$ROOT_DIR" && vagrant ssh "$FIRST_NODE" -c "
          for port in 3142 5001 5002 5003 5004 5050; do
            printf '    Port %-5s: ' \$port
            if timeout 1 bash -c '</dev/tcp/$HOST_IP/'\$port 2>/dev/null; then
              echo '✅ reachable'
            else
              echo '❌ unreachable'
            fi
          done

          echo ''
          echo '  APT proxy config:'
          cat /etc/apt/apt.conf.d/01sandbox-cache 2>/dev/null || echo '    (not configured)'

          echo ''
          echo '  containerd registry mirrors:'
          grep -A1 'registry.mirrors' /etc/containerd/config.toml 2>/dev/null | head -20 || echo '    (not configured)'
        ") || echo "  [WARN] Could not SSH into $FIRST_NODE"
        echo ""
      fi
    fi

    echo "Full APT cache dashboard: http://localhost:3142/acng-report.html"
    ;;
  *)
    usage
    exit 2
    ;;
esac
