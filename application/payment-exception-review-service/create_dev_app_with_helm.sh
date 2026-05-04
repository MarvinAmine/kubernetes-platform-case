#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"
ENV_FILE_TEMPLATE="$REPO_ROOT/.env.example"
source "$REPO_ROOT/commons/scripts/common_logging.sh"
source "$REPO_ROOT/commons/scripts/load_terraform_env.sh"

parse_args() {
    parse_silent_flag "$@"
    if [[ ${#REMAINING_ARGS[@]} -gt 0 ]]; then
        echo "Unknown argument: ${REMAINING_ARGS[0]}"
        exit 1
    fi
}

lowercase_repo_owner() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

parse_args "$@"
setup_logging "$REPO_ROOT/logs/create_dev_app_with_helm.log"

load_repo_env "$ENV_FILE" "$ENV_FILE_TEMPLATE" || exit 1
require_env_vars "$ENV_FILE" \
    SUBSCRIPTION_ID RESOURCE_GROUP AKS_CLUSTER_NAME \
    REPO_OWNER POSTGRES_SERVER_NAME POSTGRES_DATABASE_NAME POSTGRES_ADMIN_USERNAME || exit 1

export EXPECTED_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export EXPECTED_RESOURCE_GROUP="$RESOURCE_GROUP"
export EXPECTED_AKS_CLUSTER_NAME="$AKS_CLUSTER_NAME"
export APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-stage1}"
export APP_PLATFORM_NAMESPACE="${APP_PLATFORM_NAMESPACE:-$APP_NAMESPACE}"
export MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
export APP_RELEASE_NAME="${APP_RELEASE_NAME:-payment-exception-review-service}"
export APP_IMAGE_REPOSITORY="${APP_IMAGE_REPOSITORY:-ghcr.io/$(lowercase_repo_owner "$REPO_OWNER")/payment-exception-review-service}"
export APP_IMAGE_TAG="${APP_IMAGE_TAG:-latest}"
export APP_IMAGE_PULL_POLICY="${APP_IMAGE_PULL_POLICY:-IfNotPresent}"
export APP_DATABASE_HOST="${APP_DATABASE_HOST:-${POSTGRES_SERVER_NAME}.postgres.database.azure.com}"
export APP_DATABASE_NAME="${APP_DATABASE_NAME:-$POSTGRES_DATABASE_NAME}"
export APP_DATABASE_USERNAME="${APP_DATABASE_USERNAME:-$POSTGRES_ADMIN_USERNAME}"
export APP_DATABASE_SSL_MODE="${APP_DATABASE_SSL_MODE:-require}"

log_info "Validating access to the expected AKS cluster..."
run_command_with_context "AKS cluster access validated" \
    "$REPO_ROOT/platform/kubernetes-resources/scripts/cloud/validate_dev_cluster_access.sh"

run_command_with_context "Application deployed with Helm" \
    "$SCRIPT_DIR/scripts/cluster/deploy_app_with_helm.sh"

log_success "Application Helm deployment completed."
