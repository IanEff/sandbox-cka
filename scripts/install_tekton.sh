#!/usr/bin/env sh
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
kubectl apply --filename https://infra.tekton.dev/tekton-releases/dashboard/latest/release.yaml
kubectl apply --filename ~/projects/kubernetes/sandbox-kcna/tekton-dashboard-ingress.yaml