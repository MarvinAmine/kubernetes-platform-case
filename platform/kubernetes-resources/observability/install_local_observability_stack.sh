#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OBSERVABILITY_ROOT="$SCRIPT_DIR"

LOCAL_KUBE_CONTEXT="${LOCAL_KUBE_CONTEXT:-kind-local-dev}"
LOCAL_GRAFANA_VALUES_FILE="${OBSERVABILITY_ROOT}/grafana/kube-prometheus-stack-grafana-values-local.yaml"

kubectl config use-context "$LOCAL_KUBE_CONTEXT" >/dev/null
kubectl cluster-info >/dev/null

export OBSERVABILITY_EXTRA_VALUES_FILE="${OBSERVABILITY_EXTRA_VALUES_FILE:-$LOCAL_GRAFANA_VALUES_FILE}"

exec "$SCRIPT_DIR/scripts/cluster/install_shared_observability_stack.sh" "$@"
