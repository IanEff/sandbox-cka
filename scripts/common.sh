#!/bin/bash
set -e

# Optional local cache (APT + OCI registries) running on the macOS host.
# These are injected via Vagrantfile env vars.
SANDBOX_CACHE_ENABLED="${SANDBOX_CACHE_ENABLED:-0}"
SANDBOX_CACHE_HOST="${SANDBOX_CACHE_HOST:-}"
SANDBOX_CACHE_APT_PORT="${SANDBOX_CACHE_APT_PORT:-3142}"
SANDBOX_CACHE_REGISTRY_DOCKERHUB_PORT="${SANDBOX_CACHE_REGISTRY_DOCKERHUB_PORT:-5001}"
SANDBOX_CACHE_REGISTRY_K8S_PORT="${SANDBOX_CACHE_REGISTRY_K8S_PORT:-5002}"
SANDBOX_CACHE_REGISTRY_GHCR_PORT="${SANDBOX_CACHE_REGISTRY_GHCR_PORT:-5003}"
SANDBOX_CACHE_REGISTRY_QUAY_PORT="${SANDBOX_CACHE_REGISTRY_QUAY_PORT:-5004}"

cache_tcp_check() {
    local host="$1"
    local port="$2"

    if [ -z "$host" ]; then
        return 1
    fi

    # Use bash's /dev/tcp with a short timeout (no extra deps).
    timeout 1 bash -c "</dev/tcp/${host}/${port}" >/dev/null 2>&1
}

maybe_configure_apt_cache() {
    if [ "$SANDBOX_CACHE_ENABLED" != "1" ]; then
        return 0
    fi

    # Clean the host variable of any accidental whitespace or backslashes
    local clean_host
    clean_host=$(echo "$SANDBOX_CACHE_HOST" | tr -d ' \\')

    if [ -z "$clean_host" ]; then
        echo "[CACHE] SANDBOX_CACHE_HOST is empty; skipping APT cache."
        return 0
    fi

    if ! cache_tcp_check "$clean_host" "$SANDBOX_CACHE_APT_PORT"; then
        echo "[CACHE] APT cache not reachable at ${clean_host}:${SANDBOX_CACHE_APT_PORT}; continuing without it."
        return 0
    fi

    echo "[CACHE] Using APT proxy cache at ${clean_host}:${SANDBOX_CACHE_APT_PORT}"
    # Use printf to avoid any heredoc/echo escaping weirdness. 
    # Ensure exact formatting for APT config.
    printf 'Acquire::http::Proxy "http://%s:%s";\n' "$clean_host" "$SANDBOX_CACHE_APT_PORT" > /etc/apt/apt.conf.d/01sandbox-cache
    # Prevent confusing proxy mode error when requesting the proxy IP directly for remapped HTTPS
    printf 'Acquire::http::Proxy::%s "DIRECT";\n' "$clean_host" >> /etc/apt/apt.conf.d/01sandbox-cache
    printf 'Acquire::https::Proxy "DIRECT";\n' >> /etc/apt/apt.conf.d/01sandbox-cache
}

maybe_configure_containerd_registry_mirrors() {
    if [ "$SANDBOX_CACHE_ENABLED" != "1" ]; then
        return 0
    fi

    # Clean the host variable
    local clean_host
    clean_host=$(echo "$SANDBOX_CACHE_HOST" | tr -d ' \\')

    if [ -z "$clean_host" ]; then
        return 0
    fi

    # Treat k8s registry port as the "is cache up" indicator.
    if ! cache_tcp_check "$clean_host" "$SANDBOX_CACHE_REGISTRY_K8S_PORT"; then
        echo "[CACHE] Registry cache not reachable at ${clean_host}:${SANDBOX_CACHE_REGISTRY_K8S_PORT}; continuing without it."
        return 0
    fi

    # Idempotency marker.
    if grep -q "sandbox-kcna-cache" /etc/containerd/config.toml; then
        return 0
    fi

    echo "[CACHE] Configuring containerd registry mirrors via ${clean_host}"
    cat <<EOF >>/etc/containerd/config.toml

# sandbox-kcna-cache: registry mirror configuration
[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
    endpoint = ["http://${clean_host}:${SANDBOX_CACHE_REGISTRY_DOCKERHUB_PORT}"]
[plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry-1.docker.io"]
    endpoint = ["http://${clean_host}:${SANDBOX_CACHE_REGISTRY_DOCKERHUB_PORT}"]

[plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.k8s.io"]
    endpoint = ["http://${clean_host}:${SANDBOX_CACHE_REGISTRY_K8S_PORT}"]

[plugins."io.containerd.grpc.v1.cri".registry.mirrors."ghcr.io"]
    endpoint = ["http://${clean_host}:${SANDBOX_CACHE_REGISTRY_GHCR_PORT}"]

[plugins."io.containerd.grpc.v1.cri".registry.mirrors."quay.io"]
    endpoint = ["http://${clean_host}:${SANDBOX_CACHE_REGISTRY_QUAY_PORT}"]

# Allow access to host-registry (OrbStack/Docker on host)
[plugins."io.containerd.grpc.v1.cri".registry.mirrors."${clean_host}:5050"]
    endpoint = ["http://${clean_host}:5050"]
EOF
}

# Disable Swap
echo "[TASK 1] Disable Swap"
swapoff -a
sed -i '/swap/d' /etc/fstab

# DNS Fix for VirtualBox NAT Proxy on macOS (Issue: "i/o timeout" on EDNS0)
# Force systemd-resolved to use Google DNS directly, bypassing the broken VB internal proxy
echo "[TASK 1.5] Fix DNS (Google DNS Bypass)"
mkdir -p /etc/systemd/resolved.conf.d
cat <<EOF > /etc/systemd/resolved.conf.d/dns.conf
[Resolve]
DNS=8.8.8.8
FallbackDNS=1.1.1.1
EOF
systemctl restart systemd-resolved

maybe_configure_apt_cache

# Load Modules
echo "[TASK 2] Load Modules"
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Sysctl Params
echo "[TASK 3] Sysctl Params"
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# Hostname Resolution (Manual /etc/hosts for Sandbox)
echo "[TASK 3.5] Configure Hosts"
cat <<EOF >>/etc/hosts
192.168.56.10 ubukubu-control
192.168.56.21 ubukubu-node-1
192.168.56.22 ubukubu-node-2
192.168.56.23 ubukubu-node-3
EOF

# Setup Extra Disk for Storage (containerd + local-path-provisioner)
echo "[TASK 3.9] Setup Extra Disk for Storage"
TARGET_DISK="/dev/sdb"
DATA_MOUNT="/data"
if [ -b "$TARGET_DISK" ]; then
    echo "Found potential extra disk at $TARGET_DISK"
    
    # Check if already mounted
    if grep -qs "$TARGET_DISK" /proc/mounts; then
        echo "Disk $TARGET_DISK is already mounted."
    else
        # Check if formatted; if not, format it
        if ! blkid "$TARGET_DISK" >/dev/null 2>&1; then
            echo "Formatting $TARGET_DISK with ext4..."
            mkfs.ext4 -F "$TARGET_DISK"
        fi

        echo "Mounting $TARGET_DISK to ${DATA_MOUNT}..."
        mkdir -p "${DATA_MOUNT}"
        mount "$TARGET_DISK" "${DATA_MOUNT}"
        
        # Persist in fstab if not already there
        if ! grep -qs "$TARGET_DISK" /etc/fstab; then
            echo "$TARGET_DISK ${DATA_MOUNT} ext4 defaults 0 0" >> /etc/fstab
        fi
    fi
    
    # Create subdirectories for containerd and local-path-provisioner
    mkdir -p "${DATA_MOUNT}/containerd"
    mkdir -p "${DATA_MOUNT}/local-path-provisioner"
    
    # Bind mount containerd directory to /var/lib/containerd
    mkdir -p /var/lib/containerd
    if ! mountpoint -q /var/lib/containerd; then
        mount --bind "${DATA_MOUNT}/containerd" /var/lib/containerd
        # Persist bind mount in fstab
        if ! grep -qs "${DATA_MOUNT}/containerd" /etc/fstab; then
            echo "${DATA_MOUNT}/containerd /var/lib/containerd none bind 0 0" >> /etc/fstab
        fi
    fi
    
    echo "Extra storage configured:"
    echo "  - ${DATA_MOUNT}/containerd -> /var/lib/containerd (container images/data)"
    echo "  - ${DATA_MOUNT}/local-path-provisioner (PersistentVolume storage)"
else
    echo "No extra disk found at $TARGET_DISK. Using root filesystem for containers."
    # Create local-path-provisioner directory on root filesystem as fallback
    mkdir -p /data/local-path-provisioner
fi

# Install Containerd and Tools Prereqs
echo "[TASK 4] Install Containerd & Tools Prereqs"
apt-get update
# Longhorn requirements: open-iscsi, nfs-common
apt-get install -y containerd apt-transport-https ca-certificates curl gpg open-iscsi nfs-common

# Ensure iscsid is running (Longhorn requirement)
systemctl enable --now iscsid

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Align containerd's CRI sandbox (pause) image with kubeadm/Kubernetes v1.34 expectations.
# Otherwise kubeadm warns that the runtime is using an older pause image (commonly 3.8).
PAUSE_IMAGE="registry.k8s.io/pause:3.10.1"
if grep -qE '^[[:space:]]*sandbox_image[[:space:]]*=' /etc/containerd/config.toml; then
    sed -i -E "s#(^[[:space:]]*sandbox_image[[:space:]]*=[[:space:]]*\")[^\"]+(\")#\1${PAUSE_IMAGE}\2#" /etc/containerd/config.toml
else
    # Defensive fallback: insert under the CRI plugin section if the key is missing.
    # (Expected to exist in containerd defaults, but keep provisioning resilient.)
    sed -i "/^\[plugins\.\"io\.containerd\.grpc\.v1\.cri\"\]$/a\\
  sandbox_image = \"${PAUSE_IMAGE}\"" /etc/containerd/config.toml || true
fi

maybe_configure_containerd_registry_mirrors
systemctl restart containerd

# Robust APT settings
echo "[TASK 4.5] Robust APT settings"
cat <<EOF >/etc/apt/apt.conf.d/99robust
Acquire::Retries "10";
Acquire::ForceIPv4 "true";
Acquire::https::Timeout "60";
Acquire::http::Timeout "60";
Acquire::http::Pipeline-Depth "0";
EOF

# Kubernetes Version (Default to 1.34 if not set)
KUBERNETES_VERSION_MINOR="${SANDBOX_KUBERNETES_VERSION_MINOR:-1.34}"
echo "Installing Kubernetes v${KUBERNETES_VERSION_MINOR}..."

# Download the public signing key for the Kubernetes package repositories
mkdir -p -m 755 /etc/apt/keyrings

echo "Downloading Kubernetes release key..."
rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Robust download loop
for i in {1..5}; do
  echo "Attempt $i: Fetching K8s key..."
  # Unset proxy to force direct connection for this critical key
  https_proxy="" HTTPS_PROXY="" http_proxy="" HTTP_PROXY="" curl -fsSL --retry 3 --retry-delay 5 --retry-connrefused \
    "https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION_MINOR}/deb/Release.key" -o /tmp/k8s-release.key && break
  
  echo "Download failed. Sleeping before retry..."
  sleep 5
done

if [ ! -s /tmp/k8s-release.key ]; then
  echo "ERROR: Failed to download Kubernetes release key after multiple attempts."
  exit 1
fi

echo "Dearmoring key..."
gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes /tmp/k8s-release.key

echo "Adding apt repository..."
# Determine the base URL: use cache if enabled, otherwise direct
K8S_REPO_URL="https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION_MINOR}/deb/"
# Only use K8s cache if explicitly enabled (defaults to off due to pkgs.k8s.io redirection/remap stability issues)
if [ "$SANDBOX_CACHE_ENABLED" = "1" ] && [ "${SANDBOX_K8S_CACHE_ENABLED:-0}" = "1" ] && [ -n "$SANDBOX_CACHE_HOST" ]; then
    # clean_host=$(echo "$SANDBOX_CACHE_HOST" | tr -d ' \\')
    if cache_tcp_check "$SANDBOX_CACHE_HOST" "$SANDBOX_CACHE_APT_PORT"; then
        echo "[CACHE] Using cached Kubernetes repository"
        K8S_REPO_URL="http://${SANDBOX_CACHE_HOST}:${SANDBOX_CACHE_APT_PORT}/k8s.proxy/core:/stable:/v${KUBERNETES_VERSION_MINOR}/deb/"
    fi
fi

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] ${K8S_REPO_URL} /" | tee /etc/apt/sources.list.d/kubernetes.list

echo "Updating apt cache..."
apt-get update
# Pin version to prevent accidental upgrades (e.g., 1.35)
# Note: apt uses glob/regex for versioning. 1.34.* ensures we stay on 1.34.x.
# Consolidated install of K8s tools, utilities
apt-get install -y kubelet=1.34.* kubeadm=1.34.* kubectl=1.34.* \
    git vim bash-completion wget jq etcd-client \
    ripgrep bat fd-find tmux fish

apt-mark hold kubelet kubeadm kubectl

# Configure Kubelet Node IP
echo "[TASK 5.5] Configure Kubelet Node IP"
# We expect the node to have an IP in the 192.168.56.0/24 range (as set in Vagrantfile)
NODE_IP=$(ip -4 addr show | grep 192.168.56 | head -n 1 | awk '{print $2}' | cut -d/ -f1)
if [ -z "$NODE_IP" ]; then
    echo "ERROR: Could not detect private network IP (192.168.56.x). Falling back to default."
else
    echo "Detected Node IP: $NODE_IP"
    echo "KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP" | tee /etc/default/kubelet
fi

# Ergonomics: Alias and Completion
echo "[TASK 6] Ergonomics & Configuration"

# Vim Defaults
cat <<EOF >/home/vagrant/.vimrc
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
set smartindent
set bg=dark
syntax on
EOF
chown vagrant:vagrant /home/vagrant/.vimrc

# Enhanced Shell Setup
echo "[TASK 7] Enhanced Shell Setup"

# Configure Fish shell
echo "[TASK 7.5] Configure Fish Shell"
mkdir -p /home/vagrant/.config/fish
cat <<'FISHEOF' > /home/vagrant/.config/fish/config.fish
# TERM fallback
if not set -q TERM; or test "$TERM" = "dumb"
    set -gx TERM xterm-256color
end

# Kubernetes aliases and completions
abbr k kubectl
abbr kpop 'kubectl get pods --all-namespaces'
alias cat='batcat --style=plain --paging=never'
alias less='batcat --style=plain --paging=always'

# kubectl completions for fish
if type -q kubectl
    kubectl completion fish | source
end


FISHEOF
chown -R vagrant:vagrant /home/vagrant/.config/fish

# Configure Bash Shell (CKA Exam Style + Pretty)
echo "[TASK 7.5b] Configure Bash Shell"
cat <<'BASHEOF' >> /home/vagrant/.bashrc

# ============================================================================
# CKA Sandbox Bash Configuration
# ============================================================================

# Force TERM to xterm-256color (fixes ghostty's xterm-ghostty breaking pagers)
export TERM=xterm-256color

# ---- Pager Configuration (bat) ----
export PAGER="batcat --style=plain --paging=always"
export BAT_THEME="TwoDark"
alias cat='batcat --style=plain --paging=never'
alias less='batcat --style=plain --paging=always'

# ---- Colors ----
# Tomorrow Night Bright palette
C_RESET='\[\e[0m\]'
C_BOLD='\[\e[1m\]'
C_BLACK='\[\e[0;30m\]'
C_RED='\[\e[0;31m\]'
C_GREEN='\[\e[0;32m\]'
C_YELLOW='\[\e[0;33m\]'
C_BLUE='\[\e[0;34m\]'
C_MAGENTA='\[\e[0;35m\]'
C_CYAN='\[\e[0;36m\]'
C_WHITE='\[\e[0;37m\]'
C_BRIGHT_RED='\[\e[38;5;208m\]'  # Soft orange instead of hard red
C_BRIGHT_GREEN='\[\e[1;32m\]'
C_BRIGHT_YELLOW='\[\e[1;33m\]'
C_BRIGHT_BLUE='\[\e[1;34m\]'
C_BRIGHT_MAGENTA='\[\e[1;35m\]'
C_BRIGHT_CYAN='\[\e[1;36m\]'
C_BRIGHT_WHITE='\[\e[1;37m\]'

# ---- Git Branch ----
__git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# ---- Kubernetes Context ----
__k8s_context() {
    local ctx
    ctx=$(kubectl config current-context 2>/dev/null)
    if [[ -n "$ctx" ]]; then
        local ns
        ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
        [[ -z "$ns" ]] && ns="default"
        echo " ☸ ${ctx}/${ns}"
    fi
}

# ---- Prompt ----
# Format: [user@host] ~/path (git-branch) ☸ context/ns
# $ 
__set_prompt() {
    local exit_code=$?
    local prompt_char='$'
    local exit_color="${C_BRIGHT_GREEN}"
    
    if [[ $exit_code -ne 0 ]]; then
        exit_color="${C_BRIGHT_RED}"
        prompt_char="✘ $"
    fi
    
    PS1="${C_BRIGHT_CYAN}[${C_BRIGHT_GREEN}\u${C_BRIGHT_CYAN}@${C_BRIGHT_MAGENTA}\h${C_BRIGHT_CYAN}]${C_RESET} "
    PS1+="${C_BRIGHT_BLUE}\w${C_RESET}"
    PS1+="${C_BRIGHT_YELLOW}\$(__git_branch)${C_RESET}"
    PS1+="${C_CYAN}\$(__k8s_context)${C_RESET}"
    PS1+="\n${exit_color}${prompt_char}${C_RESET} "
}
PROMPT_COMMAND=__set_prompt

# ---- CKA Exam Aliases ----
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
alias kpop='kubectl get pods --all-namespaces'
alias kns='kubectl config set-context --current --namespace'
alias ctx='kubectl config use-context'

# ---- Useful Extras ----
alias ll='ls -la --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34'

# ---- History ----
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

BASHEOF

# Configure Tmux
cat <<EOF > /home/vagrant/.tmux.conf
# Mouse support
set -g mouse on

# Start windows and panes at 1
set -g base-index 1
set -g pane-base-index 1

# Colors
set -g default-terminal "screen-256color"

# Status Bar
set -g status-bg black
set -g status-fg white
set -g status-left '#[fg=green]#H '
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M '

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config file
bind r source-file ~/.tmux.conf
EOF
chown vagrant:vagrant /home/vagrant/.tmux.conf

# Set bash as default shell (CKA exam uses bash)
echo "[TASK 7.6] Set Bash as Default Shell"
chsh -s /bin/bash vagrant

# Install VirtualBox Guest Additions (Fix for Shared Folders on ARM64)
echo "[TASK 8] Install VirtualBox Guest Additions"
# Only run if vboxsf is not already loaded (though it won't be if we are fixing it)
if ! lsmod | grep -q vboxsf; then
    echo "Installing Guest Additions dependencies..."
    apt-get install -y build-essential linux-headers-$(uname -r)

    echo "Checking for Guest Additions 7.2.4 ISO..."
    ISO_PATH="/tmp/VBoxGuestAdditions.iso"
    CACHE_ISO_PATH="/vagrant/infra/artifacts/VBoxGuestAdditions_7.2.4.iso"

    if [ -f "$CACHE_ISO_PATH" ]; then
        echo "Found cached ISO at $CACHE_ISO_PATH"
        cp "$CACHE_ISO_PATH" "$ISO_PATH"
    else
        echo "Downloading Guest Additions 7.2.4 ISO..."
        wget -q https://download.virtualbox.org/virtualbox/7.2.4/VBoxGuestAdditions_7.2.4.iso -O "$ISO_PATH"
        
        # Try to cache it for next time
        if [ -d "/vagrant/infra/artifacts" ]; then
            echo "Caching ISO to $CACHE_ISO_PATH"
            cp "$ISO_PATH" "$CACHE_ISO_PATH" || echo "Warning: Failed to cache ISO"
        fi
    fi

    echo "Mounting Guest Additions ISO..."
    mkdir -p /mnt/vbox_iso
    mount -o loop /tmp/VBoxGuestAdditions.iso /mnt/vbox_iso

    echo "Running Guest Additions installer..."
    # The installer returns 2 if it fails to install kernel modules, but on a fresh system
    # with headers, it should succeed. We accept 2 just in case because it might complain
    # about X11 (which we don't have/need).
    ARCH=$(uname -m)
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        if [ -f /mnt/vbox_iso/VBoxLinuxAdditions-arm64.run ]; then
             echo "Detected ARM64. Using VBoxLinuxAdditions-arm64.run"
             /mnt/vbox_iso/VBoxLinuxAdditions-arm64.run --nox11 || true
        else
             echo "ARM64 detected but specific installer not found. Falling back to generic."
             /mnt/vbox_iso/VBoxLinuxAdditions.run --nox11 || true
        fi
    else
        if [ -f /mnt/vbox_iso/VBoxLinuxAdditions.run ]; then
            /mnt/vbox_iso/VBoxLinuxAdditions.run --nox11 || true
        else
             echo "ERROR: VBoxGuestAdditions installer not found!"
        fi
    fi
    
    echo "Cleaning up..."
    umount /mnt/vbox_iso
    rm -rf /mnt/vbox_iso /tmp/VBoxGuestAdditions.iso
    
    # Try to load the module now
    modprobe vboxsf || echo "WARNING: Failed to load vboxsf module immediately. A reboot might be required."
fi

# Attempt to mount /vagrant if not already mounted
if ! mountpoint -q /vagrant; then
    echo "Mounting /vagrant..."
    mkdir -p /vagrant
    # Ensure vboxsf is loaded
    modprobe vboxsf || true 
    mount -t vboxsf vagrant /vagrant || echo "WARNING: Failed to mount /vagrant."
else
    echo "/vagrant is already mounted."
fi

echo "[TASK 9] Provisioning Complete"


