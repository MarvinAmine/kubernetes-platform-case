#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOCAL_KUBE_CONTEXT="${LOCAL_KUBE_CONTEXT:-kind-local-dev}"

kubectl config use-context "$LOCAL_KUBE_CONTEXT" >/dev/null
kubectl cluster-info >/dev/null

exec "$SCRIPT_DIR/scripts/cluster/destroy_shared_observability_stack.sh" "$@"
