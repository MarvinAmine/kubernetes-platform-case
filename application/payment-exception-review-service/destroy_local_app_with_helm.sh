#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_ROOT/commons/scripts/common_logging.sh"

LOCAL_KUBE_CONTEXT="${LOCAL_KUBE_CONTEXT:-kind-local-dev}"
APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-local}"
APP_RELEASE_NAME="${APP_RELEASE_NAME:-payment-exception-review-service}"

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
    setup_logging "$REPO_ROOT/logs/destroy_local_app_with_helm.log"

    ensure_local_context

    run_command_with_context "Application Helm release removed" \
        "$SCRIPT_DIR/scripts/cluster/destroy_app_with_helm.sh"

    log_success "Local application Helm teardown completed."
}

main "$@"
