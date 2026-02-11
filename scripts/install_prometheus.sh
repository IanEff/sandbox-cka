#!/bin/bash
set -e

echo "[PROMETHEUS] Installing kube-prometheus-stack..."

# Ensure Helm is installed (it should be from control-plane.sh, but safety check)
if ! command -v helm &> /dev/null; then
    echo "Helm could not be found. Please ensure control-plane.sh has run."
    exit 1
fi

# Add Prometheus Community Repo
# Check if repo exists to avoid error/re-add traffic
# Redirect stderr to devnull to avoid "Error: no repositories to show" on fresh install
if ! helm repo list 2>/dev/null | grep -q "prometheus-community"; then
    echo "Adding prometheus-community helm repo..."
    # If we have a local cache proxy, we might want to use it, but for now complying with standard helm
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
fi

echo "Updating helm repos..."
helm repo update

# Create namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install kube-prometheus-stack
# We disable Grafana as requested.
# Node Exporter is enabled by default, but we'll set it ensuring it is on.
echo "Installing release 'prometheus' in namespace 'monitoring' (Backgrounded)..."
echo "Check /var/log/prometheus-install.log for progress."

# Run in background to prevent blocking Vagrant provisioning
nohup helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.enabled=false \
  --set nodeExporter.enabled=true \
  --set kubeStateMetrics.enabled=true \
  --set alertmanager.enabled=true \
  --set prometheusOperator.enabled=true \
  --set prometheus.enabled=true \
  > /var/log/prometheus-install.log 2>&1 &

echo "[PROMETHEUS] Installation triggered in background."
