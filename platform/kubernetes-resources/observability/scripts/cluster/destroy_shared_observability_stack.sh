#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OBSERVABILITY_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
RELEASE_NAME="${RELEASE_NAME:-kube-prometheus-stack}"
DASHBOARD_KUSTOMIZE_DIR="${OBSERVABILITY_ROOT}/grafana"
SYNC_RELIABILITY_DASHBOARDS_SCRIPT="${DASHBOARD_KUSTOMIZE_DIR}/sync_reliability_dashboards.sh"

if ! command -v helm >/dev/null 2>&1; then
    echo "ERROR: helm is required to destroy the observability stack."
    exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is required to destroy the observability stack."
    exit 1
fi

if helm status "$RELEASE_NAME" -n "$MONITORING_NAMESPACE" >/dev/null 2>&1; then
    helm uninstall "$RELEASE_NAME" -n "$MONITORING_NAMESPACE"
else
    echo "Observability release ${RELEASE_NAME} is not installed in namespace ${MONITORING_NAMESPACE}. Nothing to do."
fi

"$SYNC_RELIABILITY_DASHBOARDS_SCRIPT"
kubectl delete -k "$DASHBOARD_KUSTOMIZE_DIR" --ignore-not-found
