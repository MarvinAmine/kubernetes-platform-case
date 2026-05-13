#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OBSERVABILITY_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
RELEASE_NAME="${RELEASE_NAME:-kube-prometheus-stack}"
GRAFANA_ADMIN_USER="${GRAFANA_ADMIN_USER:-admin}"
GRAFANA_ADMIN_PASSWORD="${GRAFANA_ADMIN_PASSWORD:-}"
OBSERVABILITY_HELM_TIMEOUT="${OBSERVABILITY_HELM_TIMEOUT:-600s}"
VALUES_FILE_PROMETHEUS="${OBSERVABILITY_ROOT}/prometheus/kube-prometheus-stack-prometheus-values.yaml"
VALUES_FILE_GRAFANA="${OBSERVABILITY_ROOT}/grafana/kube-prometheus-stack-grafana-values.yaml"
VALUES_FILE_ALERTMANAGER="${OBSERVABILITY_ROOT}/alertmanager/kube-prometheus-stack-alertmanager-values.yaml"
OBSERVABILITY_EXTRA_VALUES_FILE="${OBSERVABILITY_EXTRA_VALUES_FILE:-}"
DASHBOARD_KUSTOMIZE_DIR="${OBSERVABILITY_ROOT}/grafana"
SYNC_RELIABILITY_DASHBOARDS_SCRIPT="${DASHBOARD_KUSTOMIZE_DIR}/sync_reliability_dashboards.sh"

if ! command -v helm >/dev/null 2>&1; then
    echo "ERROR: helm is required to install the observability stack."
    exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is required to install the observability stack."
    exit 1
fi

if [[ -z "$GRAFANA_ADMIN_PASSWORD" ]]; then
    echo "ERROR: GRAFANA_ADMIN_PASSWORD must be exported before running this script."
    exit 1
fi

kubectl get namespace "$MONITORING_NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$MONITORING_NAMESPACE"

# Custom dashboard ConfigMaps must exist before Grafana starts because the
# Helm-managed pod mounts them directly.
"$SYNC_RELIABILITY_DASHBOARDS_SCRIPT"
kubectl apply -k "$DASHBOARD_KUSTOMIZE_DIR"

TEMP_VALUES="$(mktemp)"
trap 'rm -f "$TEMP_VALUES"' EXIT

cat > "$TEMP_VALUES" <<EOF
grafana:
  adminUser: ${GRAFANA_ADMIN_USER}
  adminPassword: ${GRAFANA_ADMIN_PASSWORD}
EOF

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

HELM_VALUES_ARGS=(
    -f "$VALUES_FILE_PROMETHEUS"
    -f "$VALUES_FILE_GRAFANA"
    -f "$VALUES_FILE_ALERTMANAGER"
    -f "$TEMP_VALUES"
)

if [[ -n "$OBSERVABILITY_EXTRA_VALUES_FILE" ]]; then
    HELM_VALUES_ARGS+=(-f "$OBSERVABILITY_EXTRA_VALUES_FILE")
fi

helm upgrade --install "$RELEASE_NAME" \
    prometheus-community/kube-prometheus-stack \
    --namespace "$MONITORING_NAMESPACE" \
    --create-namespace \
    "${HELM_VALUES_ARGS[@]}" \
    --wait \
    --timeout "$OBSERVABILITY_HELM_TIMEOUT"

echo 
echo "Grafana:"
echo "  kubectl -n ${MONITORING_NAMESPACE} port-forward svc/${RELEASE_NAME}-grafana 3000:80"
echo
echo "Prometheus:"
echo "  kubectl -n ${MONITORING_NAMESPACE} port-forward svc/${RELEASE_NAME}-prometheus 9090:9090"
