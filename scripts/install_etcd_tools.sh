#!/bin/bash
set -e

# Install etcd tools (etcd, etcdctl, etcdutl)
# This overrides/supplements the 'etcd-client' apt package which often lacks etcdutl/etcd server binary.

ETCD_VERSION="v3.5.16"
DOWNLOAD_URL="https://github.com/etcd-io/etcd/releases/download"

echo "[ETCD] Installing etcd tools ${ETCD_VERSION}..."

ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" == "aarch64" ]; then
    ARCH="arm64"
elif [ "$ARCH" == "armv7l" ]; then
    ARCH="arm"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Clean up any partials
rm -f /tmp/etcd-${ETCD_VERSION}-linux-${ARCH}.tar.gz
rm -rf /tmp/etcd-download

TARBALL="etcd-${ETCD_VERSION}-linux-${ARCH}.tar.gz"
CACHE_DIR="/vagrant/infra/artifacts"
DOWNLOAD_SUCCESS=0

# Try Local Artifact Cache
if [ -f "${CACHE_DIR}/${TARBALL}" ]; then
    echo "Found cached Etcd tools at ${CACHE_DIR}/${TARBALL}"
    # Use -n to avoid creating conflicting symlinks or copy issues
    cp "${CACHE_DIR}/${TARBALL}" "/tmp/${TARBALL}"
    DOWNLOAD_SUCCESS=1
fi

if [ "$DOWNLOAD_SUCCESS" -eq 0 ]; then
    # Download
    curl -L ${DOWNLOAD_URL}/${ETCD_VERSION}/${TARBALL} -o /tmp/${TARBALL}
    
    # Cache it
    if [ -d "${CACHE_DIR}" ]; then
        echo "Caching Etcd tools to ${CACHE_DIR}/${TARBALL}"
        cp "/tmp/${TARBALL}" "${CACHE_DIR}/${TARBALL}"
    fi
fi

# Extract
mkdir -p /tmp/etcd-download
tar xzvf /tmp/${TARBALL} -C /tmp/etcd-download --strip-components=1

# Install to /usr/local/bin (taking precedence over /usr/bin)
mv /tmp/etcd-download/etcd /usr/local/bin/
mv /tmp/etcd-download/etcdctl /usr/local/bin/
mv /tmp/etcd-download/etcdutl /usr/local/bin/

chmod +x /usr/local/bin/etcd
chmod +x /usr/local/bin/etcdctl
chmod +x /usr/local/bin/etcdutl

# Verify
echo "[ETCD] Verifying installation..."
/usr/local/bin/etcd --version
/usr/local/bin/etcdctl version
/usr/local/bin/etcdutl version

# Clean up
rm -f /tmp/etcd-${ETCD_VERSION}-linux-${ARCH}.tar.gz
rm -rf /tmp/etcd-download

echo "[ETCD] Installation complete."
