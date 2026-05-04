#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"
ENV_FILE_TEMPLATE="$REPO_ROOT/.env.example"
source "$REPO_ROOT/commons/scripts/common_logging.sh"
source "$REPO_ROOT/commons/scripts/load_terraform_env.sh"

LOCAL_KUBE_CONTEXT="${LOCAL_KUBE_CONTEXT:-kind-local-dev}"
APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-local}"
MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
POSTGRES_DEPLOYMENT_NAME="${POSTGRES_DEPLOYMENT_NAME:-payment-review-postgres}"
POSTGRES_SERVICE_NAME="${POSTGRES_SERVICE_NAME:-payment-review-postgres}"
POSTGRES_DATABASE_NAME="${POSTGRES_DATABASE_NAME:-payment_exception_review}"
POSTGRES_LOCAL_USERNAME="${POSTGRES_LOCAL_USERNAME:-postgres}"

parse_args() {
    parse_silent_flag "$@"
    if [[ ${#REMAINING_ARGS[@]} -gt 0 ]]; then
        echo "Unknown argument: ${REMAINING_ARGS[0]}"
        exit 1
    fi
}

ensure_env() {
    load_repo_env "$ENV_FILE" "$ENV_FILE_TEMPLATE" || exit 1
    require_env_vars "$ENV_FILE" POSTGRES_ADMIN_PASSWORD GRAFANA_ADMIN_PASSWORD || exit 1
}

ensure_tools() {
    for tool in kubectl helm docker kind; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "ERROR: $tool is required."
            exit 1
        fi
    done
}

ensure_local_context() {
    kubectl config use-context "$LOCAL_KUBE_CONTEXT" >/dev/null
    kubectl cluster-info >/dev/null
}

apply_platform_boundary() {
    run_command_with_context "Platform runtime boundary applied" \
        "$SCRIPT_DIR/scripts/cluster/apply_platform_runtime_boundary.sh"
}

apply_runtime_secret() {
    export APP_NAMESPACE
    run_command_with_context "Runtime database password secret injection" \
        "$SCRIPT_DIR/scripts/cluster/apply_runtime_db_secret.sh"
}

apply_local_postgres() {
    run_command_with_context "Local PostgreSQL deployed" \
        "$SCRIPT_DIR/scripts/cluster/deploy_local_postgres.sh"
}

install_observability() {
    export LOCAL_KUBE_CONTEXT
    export MONITORING_NAMESPACE
    run_command_with_context "Shared observability stack installation" \
        "$SCRIPT_DIR/observability/install_local_observability_stack.sh"
}

main() {
    parse_args "$@"
    setup_logging "$REPO_ROOT/logs/create_local_platform.log"

    ensure_env
    ensure_tools
    ensure_local_context
    apply_platform_boundary
    apply_runtime_secret
    apply_local_postgres
    install_observability

    log_success "Local platform provisioning completed."
}

main "$@"
