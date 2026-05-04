#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
RELEASE_NAME="${RELEASE_NAME:-kube-prometheus-stack}"

if ! command -v helm >/dev/null 2>&1; then
    echo "ERROR: helm is required to destroy the observability stack."
    exit 1
fi

if helm status "$RELEASE_NAME" -n "$MONITORING_NAMESPACE" >/dev/null 2>&1; then
    helm uninstall "$RELEASE_NAME" -n "$MONITORING_NAMESPACE"
else
    echo "Observability release ${RELEASE_NAME} is not installed in namespace ${MONITORING_NAMESPACE}. Nothing to do."
fi
