#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_ROOT/commons/scripts/common_logging.sh"

LOCAL_KUBE_CONTEXT="${LOCAL_KUBE_CONTEXT:-kind-local-dev}"
APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-local}"
MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"

parse_args() {
    parse_silent_flag "$@"
    if [[ ${#REMAINING_ARGS[@]} -gt 0 ]]; then
        echo "Unknown argument: ${REMAINING_ARGS[0]}"
        exit 1
    fi
}

ensure_local_context() {
    kubectl config use-context "$LOCAL_KUBE_CONTEXT" >/dev/null
    kubectl cluster-info >/dev/null
}

main() {
    parse_args "$@"
    setup_logging "$REPO_ROOT/logs/destroy_local_platform.log"

    ensure_local_context

    export LOCAL_KUBE_CONTEXT
    export MONITORING_NAMESPACE
    run_command_with_context "Shared observability stack removed" \
        "$SCRIPT_DIR/observability/destroy_local_observability_stack.sh"

    export APP_NAMESPACE
    run_command_with_context "Local PostgreSQL removed" \
        "$SCRIPT_DIR/scripts/cluster/destroy_local_postgres.sh"

    export APP_NAMESPACE
    run_command_with_context "Runtime database password secret removed" \
        "$SCRIPT_DIR/scripts/cluster/remove_runtime_db_secret.sh"

    kubectl delete namespace "$APP_NAMESPACE" --ignore-not-found=true
    kubectl delete namespace "$MONITORING_NAMESPACE" --ignore-not-found=true

    log_success "Local platform teardown completed."
}

main "$@"
