#!/bin/bash
set -e

kubectl create ns helm-ns --dry-run=client -o yaml | kubectl apply -f -

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "ERROR: Helm is not installed. Please install Helm first."
    exit 1
fi

# Create a simple chart with a misconfiguration (references non-existent SA)
CHART_DIR="/tmp/metrics-app-chart"
rm -rf "$CHART_DIR"
mkdir -p "$CHART_DIR/templates"

cat > "$CHART_DIR/Chart.yaml" <<EOF
apiVersion: v2
name: metrics-app
version: 1.0.0
description: A simple metrics application
EOF

cat > "$CHART_DIR/values.yaml" <<EOF
replicaCount: 1
image: busybox:stable
serviceAccountName: metrics-sa
EOF

cat > "$CHART_DIR/templates/deployment.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      serviceAccountName: {{ .Values.serviceAccountName }}
      containers:
      - name: app
        image: {{ .Values.image }}
        command: ["/bin/sh", "-c", "while true; do echo metrics; sleep 60; done"]
EOF

# Install the chart - it will create but pods will fail due to missing SA
helm upgrade --install metrics-app "$CHART_DIR" -n helm-ns --wait=false 2>/dev/null || true

echo "Setup complete. Helm release 'metrics-app' deployed but pods failing."
echo ""
echo "Hint: Check why pods are not starting and fix using Helm."
