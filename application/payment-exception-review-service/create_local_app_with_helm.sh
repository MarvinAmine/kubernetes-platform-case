#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_ROOT/commons/scripts/common_logging.sh"

LOCAL_KUBE_CONTEXT="${LOCAL_KUBE_CONTEXT:-kind-local-dev}"
APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-local}"
MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
APP_RELEASE_NAME="${APP_RELEASE_NAME:-payment-exception-review-service}"
APP_IMAGE_REPOSITORY="${APP_IMAGE_REPOSITORY:-payment-exception-review-service}"
APP_IMAGE_TAG="${APP_IMAGE_TAG:-local}"
POSTGRES_SERVICE_NAME="${POSTGRES_SERVICE_NAME:-payment-review-postgres}"
POSTGRES_DATABASE_NAME="${POSTGRES_DATABASE_NAME:-payment_exception_review}"
POSTGRES_LOCAL_USERNAME="${POSTGRES_LOCAL_USERNAME:-postgres}"
KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-${LOCAL_KUBE_CONTEXT#kind-}}"

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

build_and_load_image() {
    docker build -t "${APP_IMAGE_REPOSITORY}:${APP_IMAGE_TAG}" "$SCRIPT_DIR"
    kind load docker-image "${APP_IMAGE_REPOSITORY}:${APP_IMAGE_TAG}" --name "$KIND_CLUSTER_NAME"
}

deploy_with_helm() {
    run_command_with_context "Application deployed with Helm" \
        "$SCRIPT_DIR/scripts/cluster/deploy_app_with_helm.sh"
}

main() {
    parse_args "$@"
    setup_logging "$REPO_ROOT/logs/create_local_app_with_helm.log"

    ensure_local_context
    build_and_load_image
    deploy_with_helm

    log_success "Local application deployment completed."
}

main "$@"
